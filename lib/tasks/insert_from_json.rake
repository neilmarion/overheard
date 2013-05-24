namespace :insert do
  task :from_json => :environment do
    text_file = File.open("data/data_1.json", 'r')
    posts = JSON.parse(text_file.read)
    posts['feed']['data'].each do |post|
      Post.create(content: post['message'], fb_id: post['id'], user_fb_id: post['from']['id'], from_name: post['from']['name'],
          fb_created_at: Time.new(post['created_time']), fb_updated_at: Time.new(post['updated_time'])) if post['likes'] && post['likes']['count'].to_i > 250 
    end


    for i in 2..422
      text_file = File.open("data/data_#{i}.json", 'r')
      posts = JSON.parse(text_file.read)
      posts['data'].each_with_index do |post, i|
        puts i
        #puts post.inspect unless post['likes']
        Post.create(content: post['message'], fb_id: post['id'], user_fb_id: post['from']['id'], from_name: post['from']['name'],
          fb_created_at: Time.new(post['created_time']), fb_updated_at: Time.new(post['updated_time'])) if post['likes'] && post['likes']['count'].to_i > 250 
      end
    end
  end
end
