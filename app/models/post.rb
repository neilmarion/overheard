class Post < ActiveRecord::Base
  attr_accessible :content, :fb_created_at, :fb_id, :fb_updated_at, :user_fb_id, :from_name

  belongs_to :user

  default_scope order('created_at ASC')

  scope :paginate, lambda { |page|
    page(page).per(PAGINATION['posts']) }

  scope :where_content_matches, lambda { |query|
    where("to_tsvector('english', content) @@ plainto_tsquery(:q)", q: query) }

  def self.text_search(query)
    if query.present?
      where_content_matches(query)
    else
      scoped
    end
  end
end
