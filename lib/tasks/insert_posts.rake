require 'open-uri'
require 'json'

namespace :fb do
  task :insert_posts => :environment do
    redis = Redis.new(:host => 'localhost', :port => 6379)

    file_log = File.open(Rails.root.join('log', "#{Time.now.to_i}insert_posts.log"), "w")
    file_log.puts "Generating fb access_token..."
    puts "Generating fb access_token..."
    url = "https://graph.facebook.com/oauth/access_token?client_id=#{FB['key']}&client_secret=#{FB['secret']}&grant_type=client_credentials" 
    access_token_io = open(url)
    a = access_token_io.gets
    url = "https://graph.facebook.com/326350678368?fields=feed&#{a}"
    first_page_posts = JSON.parse(open(URI.encode(url)).read)

    a = a.split('=')[1]

    #first page (special case)
    puts "Generating Koala Instance"
    graph = Koala::Facebook::API.new(a)

    first_page_posts['feed']['data'].each do |post|
      puts post['id']
      likes =  graph.fql_query("SELECT like_info.like_count FROM stream WHERE post_id = '#{post['id']}'").first['like_info']['like_count'].to_i
      next unless likes 
      entry = Post.find_or_create_by_fb_id(fb_id: post['id'], user_fb_id: post['from']['id'], from_name: post['from']['name'],
        fb_created_at: Time.parse(post['created_time']), fb_updated_at: Time.parse(post['updated_time']), content: post['message'], 
        photo_url: post['type'] == "photo" ? post['picture'] : nil ) if likes > 250
      if entry
        file_log.puts "#{Time.now} Creating post for #{post['id']} with #{likes} likes"
        puts "#{Time.now} Creating post for #{post['id']} with #{likes} likes"
      end
    end

    #succceeding pages

    page_posts = {}
    page_posts['paging'] = {}
    puts "next page not null" if redis.get('next_page')
    page_posts['paging']['next'] = redis.get('next_page') || first_page_posts['feed']['paging']['next']

    while !page_posts['paging'].nil?
      file_log.puts "fetching next page of posts..."
      puts "fetching next page of posts..."
      page_posts = JSON.parse(open(URI.encode(page_posts['paging']['next'])).read)
      puts "next page: #{page_posts['paging']['next']}"
      redis.set('next_page', page_posts['paging']['next'])
      page_posts['data'].each do |post|
        likes =  graph.fql_query("SELECT like_info.like_count FROM stream WHERE post_id = '#{post['id']}'").first['like_info']['like_count'].to_i
        next unless likes 
        entry = Post.find_or_create_by_fb_id(fb_id: post['id'], user_fb_id: post['from']['id'], from_name: post['from']['name'],
          fb_created_at: Time.parse(post['created_time']), fb_updated_at: Time.parse(post['updated_time']), content: post['message'], 
          photo_url: post['type'] == "photo" ? post['picture'] : nil ) if likes > 250 
        if entry
          file_log.puts "#{Time.now} Creating post for #{post['id']} with #{post['likes']['count']} likes"
          puts "#{Time.now} Creating post for #{post['id']} with #{likes} likes"
        end
      end
    end
  end
end
