require 'spec_helper'

describe Post do
  describe 'text_search' do
    let(:post){ FactoryGirl.create(:post) }

    it 'returns results' do
      Post.text_search(post.content).should eq [post]
    end 

    it 'returns no results' do
      Post.text_search("xxx").should eq []
    end 

    describe 'query not present' do
      it 'returns all results' do
        Post.text_search(nil).should eq [post]
      end 
    end 
  end
end
