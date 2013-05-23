namespace :insert do
  task :from_json => :environment do
    for i in 2..427
      text_file = File.open("data/data_#{i}.json", 'r')
      puts "json file #{i}"
      post = JSON.parse(text_file.read)
      post['data'].each_with_index do |post, i|
        Post.create(content: post['message'], fb_id: post['id'], user_fb_id: post['from']['id'],
          fb_created_at: post['created_time'], fb_updated_at: post['updated_time']) if post['likes'] && post['likes']['count'].to_i > 1000
      end
    end
  end
end
