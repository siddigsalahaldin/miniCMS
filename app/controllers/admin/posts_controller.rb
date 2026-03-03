module Admin
  class PostsController < BaseController
    before_action :set_post, only: [:show, :edit, :update, :destroy, :publish, :unpublish]
    
    def index
      @scope = params[:scope] || 'all'
      @posts = case @scope
               when 'published'
                 Post.published
               when 'draft'
                 Post.draft
               else
                 Post.all
               end
      @posts = @posts.includes(:user).recent.limit(100)
    end
    
    def show
    end
    
    def edit
    end
    
    def update
      if @post.update(post_params)
        redirect_to admin_post_path(@post), notice: "Post was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @post.destroy
      redirect_to admin_posts_path, notice: "Post was successfully destroyed."
    end
    
    def publish
      @post.update(published: true)
      redirect_to admin_post_path(@post), notice: "Post was published."
    end
    
    def unpublish
      @post.update(published: false)
      redirect_to admin_post_path(@post), notice: "Post was unpublished."
    end
    
    private
    
    def set_post
      @post = Post.friendly.find(params[:id])
    end
    
    def post_params
      params.require(:post).permit(:title, :body, :published, :user_id)
    end
  end
end
