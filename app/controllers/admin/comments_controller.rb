module Admin
  class CommentsController < BaseController
    before_action :set_comment, only: [:show, :edit, :update, :destroy]
    
    def index
      @comments = Comment.includes(:user, :commentable).recent.limit(100)
    end
    
    def show
    end
    
    def edit
    end
    
    def update
      if @comment.update(comment_params)
        redirect_to admin_comment_path(@comment), notice: "Comment was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @comment.destroy
      redirect_to admin_comments_path, notice: "Comment was successfully destroyed."
    end
    
    private
    
    def set_comment
      @comment = Comment.find(params[:id])
    end
    
    def comment_params
      params.require(:comment).permit(:body)
    end
  end
end
