FactoryGirl.define do
  factory :post do
    sequence(:content) { |n| "Post Content #{n}" }
    user { FactoryGirl.build(:user_facebook) }
  end 
end
