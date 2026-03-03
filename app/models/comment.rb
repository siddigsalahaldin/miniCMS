class Comment < ApplicationRecord
  # Include notifiable for notifications
  include Notifiable

  # Relationships
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  belongs_to :parent, class_name: "Comment", optional: true, foreign_key: :parent_id

  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :reactions, as: :reactable, dependent: :destroy

  # Validations
  validates :body, presence: true, length: { minimum: 1, maximum: 5000 }

  # Scopes
  scope :root_level, -> { where(parent_id: nil) }
  scope :for_commentable, ->(commentable) { where(commentable: commentable) }
  scope :recent, -> { order(created_at: :desc) }
  scope :with_user, -> { includes(:user) }

  # Callbacks
  before_validation :set_depth, if: :will_save_change_to_parent_id?
  after_create :create_comment_notification

  # Instance methods
  def root?
    parent_id.nil?
  end

  def reply_to_comment
    parent
  end

  def reply_to_user
    parent&.user
  end

  def child_comments_count
    replies.count
  end

  def favorited_by?(user)
    return false unless user
    reactions.exists?(user: user, reaction_type: Reaction.reaction_types[:like])
  end

  # Create notification when a comment is created
  def create_comment_notification
    # Notify post owner if someone comments on their post
    if commentable.is_a?(Post) && commentable.user_id != user_id
      commentable.notify_owner!(
        actor: user,
        notification_type: Notification::TYPES[:comment_on_post],
        params: { comment_body: body.to_s.truncate(50) }
      )
    end

    # Notify comment owner if someone replies to their comment
    if parent && parent.user_id != user_id
      parent.notify_owner!(
        actor: user,
        notification_type: Notification::TYPES[:reply_to_comment],
        params: { comment_body: body.to_s.truncate(50) }
      )
    end
  end

  # Class methods for N+1 optimization
  class << self
    def with_associations
      includes(:user, :parent, :replies, reactions: :user)
    end

    def tree_for(commentable)
      where(commentable: commentable).includes(:user, :parent, :replies)
    end
  end

  private

  def set_depth
    # Could add depth caching if needed for very deep nesting
    # For now, we rely on the parent relationship
  end
end
