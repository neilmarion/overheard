require 'open-uri'
require 'json'

namespace :fb do
  task :insert_posts => :environment do
    file_log = File.open(Rails.root.join('log', "#{Time.now.to_i}insert_posts.log"), "w")
    file_log.puts "Generating fb access_token..."
    puts "Generating fb access_token..."
    url = "https://graph.facebook.com/oauth/access_token?client_id=#{FB['key']}&client_secret=#{FB['secret']}&grant_type=client_credentials" 
    access_token_io = open(url)
    url = "https://graph.facebook.com/326350678368?fields=feed&#{access_token_io.gets}"
    first_page_posts = JSON.parse(open(URI.encode(url)).read)

    #first page (special case)

    first_page_posts['feed']['data'].each do |post|
      next unless post['likes']
      entry = Post.find_or_create_by_fb_id(fb_id: post['id'], user_fb_id: post['from']['id'], from_name: post['from']['name'],
        fb_created_at: Time.parse(post['created_time']), fb_updated_at: Time.parse(post['updated_time']), content: post['message'], 
        photo_url: post['type'] == "photo" ? post['picture'] : nil ) if post['likes'] && post['likes']['count'].to_i > 250
      if entry
        file_log.puts "#{Time.now} Creating post for #{post['id']} with #{post['likes']['count']} likes"
        puts "#{Time.now} Creating post for #{post['id']} with #{post['likes']['count']} likes"
      end
    end

    #succceeding pages

    page_posts = {}
    page_posts['paging'] = {}
    page_posts['paging']['next'] = first_page_posts['feed']['paging']['next']

    while !page_posts['paging'].nil?
      file_log.puts "fetching next page of posts..."
      puts "fetching next page of posts..."
      page_posts = JSON.parse(open(URI.encode(page_posts['paging']['next'])).read)
      page_posts['data'].each do |post|
        next unless post['likes']
        entry = Post.find_or_create_by_fb_id(fb_id: post['id'], user_fb_id: post['from']['id'], from_name: post['from']['name'],
          fb_created_at: Time.parse(post['created_time']), fb_updated_at: Time.parse(post['updated_time']), content: post['message'], 
          photo_url: post['type'] == "photo" ? post['picture'] : nil ) if post['likes'] && post['likes']['count'].to_i > 250
        if entry
          file_log.puts "#{Time.now} Creating post for #{post['id']} with #{post['likes']['count']} likes"
          puts "#{Time.now} Creating post for #{post['id']} with #{post['likes']['count']} likes"
        end
      end
    end
  end
end
