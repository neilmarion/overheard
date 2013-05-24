class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :content
      t.string :fb_id
      t.string :from_name
      t.string :user_fb_id
      t.datetime :fb_created_at
      t.datetime :fb_updated_at

      t.timestamps
    end
  end
end
