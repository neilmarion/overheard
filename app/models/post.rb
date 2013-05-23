class Post < ActiveRecord::Base
  attr_accessible :content, :fb_created_at, :fb_id, :fb_updated_at, :user_fb_id

  belongs_to :user
end
