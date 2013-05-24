namespace :insert do
  task :from_json => :environment do
    for i in 2..427
      text_file = File.open("data/data_#{i}.json", 'r')
      puts "json file #{i}"
      posts = JSON.parse(text_file.read)
      posts['data'].each_with_index do |post, i|
        puts post.inspect unless post['likes']
        Post.create(content: post['message'], fb_id: post['id'], user_fb_id: post['from']['id'], from_name: post['from']['name'],
          fb_created_at: post['created_time'], fb_updated_at: post['updated_time']) if post['likes'] #&& post['likes']['count'].to_i > 500 
      end
    end
  end
end
