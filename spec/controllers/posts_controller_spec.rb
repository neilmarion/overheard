require 'spec_helper'

describe PostsController do
  describe 'index' do
    let!(:user_1){ FactoryGirl.build(:user_facebook) }

    it 'returns all search results in desc chronological order' do
      post = FactoryGirl.create(:post)
      get :index
      assigns(:posts).should eq [post]
    end 
  end
end
