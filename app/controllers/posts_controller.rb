class PostsController < ApplicationController 
  def index
    @posts = Post.text_search(params[:query]).paginate params[:page]
  end

  private

    def post_params
      params.require(:post).permit(:page)
    end
end
