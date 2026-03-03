class SearchController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  # GET /search
  def index
    @query = params[:q].to_s.strip
    @filter = params[:filter] || 'all' # all, posts, users, comments

    if @query.present?
      case @filter
      when 'posts'
        @results = Post.published.search_with_body(@query).with_user.recent.limit(50)
        @total = @results.count
      when 'users'
        @results = User.where("username LIKE ?", "%#{@query}%").limit(20)
        @total = @results.count
      when 'comments'
        @results = Comment.where("body LIKE ?", "%#{@query}%").includes(:user, :commentable).recent.limit(50)
        @total = @results.count
      else
        # Search all
        @posts = Post.published.search_with_body(@query).with_user.recent.limit(20)
        @users = User.where("username LIKE ?", "%#{@query}%").limit(10)
        @comments = Comment.where("body LIKE ?", "%#{@query}%").includes(:user, :commentable).recent.limit(20)
        @total = (@posts&.count || 0) + (@users&.count || 0) + (@comments&.count || 0)
      end

      # Log search if user is signed in
      SearchLog.create!(
        query: @query,
        result_count: @total,
        user: current_user
      ) if user_signed_in?
    else
      @results = []
      @total = 0
    end

    # Popular searches
    @popular_searches = SearchLog.select(:query)
      .group(:query)
      .order(Arel.sql('COUNT(*) DESC'))
      .limit(10)
      .pluck(:query)
  end
end
