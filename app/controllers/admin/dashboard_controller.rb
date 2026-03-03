module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        posts: Post.count,
        published_posts: Post.published.count,
        users: User.count,
        comments: Comment.count,
        recent_posts: Post.recent.limit(5),
        recent_users: User.recent.limit(5),
        recent_comments: Comment.includes(:user, :commentable).recent.limit(5)
      }
    end
  end
end
