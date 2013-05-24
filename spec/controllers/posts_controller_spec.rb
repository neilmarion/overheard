require 'spec_helper'

describe PostsController do
  describe 'index' do
    let!(:user_1){ FactoryGirl.build(:user_facebook) }

    it 'returns all search results in desc chronological order according to fb_created_at' do
      post = FactoryGirl.create(:post)
      get :index
      assigns(:posts).should eq [post]
    end 

    describe "full-text search" do
      before(:each) do
        @query = "magnanimous"
        word = "Other"
        @jiberish = "xxx"
        @post_1 = FactoryGirl.create(:post, content: @query, fb_created_at: Time.now - 3)    
        @post_2 = FactoryGirl.create(:post, content: @query, fb_created_at: Time.now)
        @post_3 = FactoryGirl.create(:post, content: @query, fb_created_at: Time.now + 3)
      end 

      it "returns all posts in desc chronological order if query is blank" do
        get :index, {query: ""} 
        assigns(:posts).should eq [@post_3, @post_2, @post_1]
      end 

      it "returns no search results" do
        get :index, { query: @jiberish }
        assigns(:posts).should eq []
      end 

      it "returns (plainly) by significance (ts_rank)" do
        Post.destroy(@post_1.id)
        get :index, { query: @query }
        assigns(:posts).should eq [@post_3, @post_2]
      end

      it "returns (plainly) by reputation values" do
        pending
        Post.destroy(@post_2.id)
        @post_1.add_evaluation(:question_reputation, 10, user_1)
        get :index, { query: @query }
        assigns(:posts).should eq [@post_1, @post_3]
      end
    end

  end



end
