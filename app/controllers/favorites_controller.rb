class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:create, :destroy]

  # GET /favorites
  def index
    @favorites = current_user.favorites
                              .with_associations
                              .recent
                              .limit(50)
    @posts = @favorites.map(&:post)
  end

  # POST /posts/:post_id/favorite
  def create
    @favorite = current_user.favorites.find_or_create_by(post: @post)
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post, notice: "Post was added to your favorites." }
      format.json { render :show, status: :created, location: @post }
    end
  end

  # DELETE /posts/:post_id/unfavorite
  def destroy
    @favorite = current_user.favorites.find_by(post: @post)
    @favorite&.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post, notice: "Post was removed from your favorites." }
      format.json { head :no_content }
    end
  end

  # POST /posts/:post_id/toggle_favorite
  def toggle
    @favorite = current_user.favorites.find_by(post: @post)
    
    if @favorite
      @favorite.destroy
      favorited = false
    else
      @favorite = current_user.favorites.create!(post: @post)
      favorited = true
    end

    respond_to do |format|
      format.turbo_stream
      format.html do
        notice = favorited ? "Post was added to your favorites." : "Post was removed from your favorites."
        redirect_to @post, notice: notice
      end
      format.json { render :show, status: :ok }
    end
  end

  private

  def set_post
    @post = Post.friendly.find(params[:id])
  end
end
