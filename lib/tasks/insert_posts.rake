require 'open-uri'
require 'json'

namespace :fb do
  task :insert_posts => :environment do
    puts "Generating fb access_token"
    url = "https://graph.facebook.com/oauth/access_token?client_id=#{FB['key']}&client_secret=#{FB['secret']}&grant_type=client_credentials" 
    access_token_io = open(url)
    url = "https://graph.facebook.com/326350678368?fields=feed&#{access_token_io.gets}"
    first_page_posts = JSON.parse(open(URI.encode(url)).read)

    #first page (special case)

    first_page_posts['feed']['data'].each do |post|
      puts "Creating post for #{post['id']} with #{post['likes']['count']} likes"
      Post.find_or_create_by_fb_id(fb_id: post['id'], user_fb_id: post['from']['id'], from_name: post['from']['name'],
        fb_created_at: Time.parse(post['created_time']), fb_updated_at: Time.parse(post['updated_time']), content: post['message']) if post['likes'] &&
        post['likes']['count'].to_i > 250
      
    end
  end
end
