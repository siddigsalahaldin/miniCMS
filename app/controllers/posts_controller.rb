class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy, :publish, :unpublish]
  before_action :authorize_user!, only: [:edit, :update, :destroy, :publish, :unpublish]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.published
                 .with_user
                 .with_rich_text_body
                 .includes(comments: :user, reactions: :user)
                 .recent
                 .limit(20)

    @featured_posts = Post.published
                          .with_user
                          .recent
                          .limit(5)
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @comments = @post.comments
                     .root_level
                     .with_user
                     .includes(:replies, :reactions)
                     .recent

    @reactions = @post.reactions.with_user.recent.limit(10)
    @reaction = current_user ? @post.reactions.find_by(user: current_user) : nil
  end

  # GET /posts/new
  def new
    @post = current_user.posts.build
    @post.body = ActionText::RichText.new(name: :body)
  end

  # GET /posts/1/edit
  def edit; end

  # POST /posts
  # POST /posts.json
  def create
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # PATCH /posts/1/publish
  def publish
    @post.update(published: true)
    redirect_to @post, notice: "Post was published."
  end

  # PATCH /posts/1/unpublish
  def unpublish
    @post.update(published: false)
    redirect_to @post, notice: "Post was unpublished."
  end

  private

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  def authorize_user!
    return if can_edit_post?(@post)

    redirect_to root_path, alert: "You are not authorized to perform this action."
  end

  def post_params
    params.require(:post).permit(:title, :body, :published)
  end
end
