class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  # GET /posts/:post_id/comments/new
  def new
    @comment = @commentable.comments.build
    @comment.parent = Comment.find(params[:parent_id]) if params[:parent_id].present?
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    # Set parent if this is a reply to another comment
    if params[:parent_id].present?
      @comment.parent = Comment.find(params[:parent_id])
    end

    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to @commentable, notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @commentable }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.prepend("comments", partial: "comments/form", locals: { comment: @comment }) }
        format.html { render "posts/show", status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /comments/1
  def show; end

  # GET /comments/1/edit
  def edit; end

  # PATCH/PUT /comments/1
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @commentable, notice: "Comment was successfully updated." }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @commentable, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_commentable
    # Find the commentable object (Post or Comment)
    if params[:post_id]
      @commentable = Post.friendly.find(params[:post_id])
    elsif params[:comment_id]
      @commentable = Comment.find(params[:comment_id])
    end
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def authorize_user!
    return if can_edit_comment?(@comment)

    redirect_to @commentable, alert: "You are not authorized to perform this action."
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
