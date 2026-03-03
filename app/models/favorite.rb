class Favorite < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :post

  # Validations
  validates :user_id, uniqueness: { scope: :post_id, message: "has already favorited this post" }

  # Scopes
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :for_post, ->(post) { where(post_id: post.id) }
  scope :recent, -> { order(created_at: :desc) }

  # Class methods for N+1 optimization
  class << self
    def with_associations
      includes(:user, :post)
    end

    def posts_for_user(user)
      where(user: user).includes(:post).map(&:post)
    end
  end
end
