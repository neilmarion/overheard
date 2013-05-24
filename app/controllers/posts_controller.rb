class PostsController < ApplicationController 
  def index
    @posts = Post.text_search(params[:query]).paginate params[:page]
  end
end
