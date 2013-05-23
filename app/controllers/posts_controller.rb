class PostsController < ApplicationController 
  def index
    @posts = Post.paginate params[:page]
  end
end
