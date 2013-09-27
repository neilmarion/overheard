FactoryGirl.define do
  factory :post do
    sequence(:content) { |n| "Post Content #{n}" }
  end 
end
