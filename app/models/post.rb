class Post < ActiveRecord::Base
  belongs_to :user

  default_scope { order('fb_created_at DESC') }

  scope :paginate, lambda { |page|
    page(page).per(PAGINATION['posts']) }

  scope :where_content_matches, lambda { |query|
    where("to_tsvector('english', content) @@ plainto_tsquery(:q)", q: query) }

  def self.text_search(query)
    if query.present?
      where_content_matches(query)
    else
      all 
    end
  end
end
