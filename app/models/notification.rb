class Notification < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true

  # Validations
  validates :notification_type, presence: true

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Types of notifications
  TYPES = {
    comment_on_post: "comment_on_post",
    reply_to_comment: "reply_to_comment",
    user_followed_you: "user_followed_you",
    new_post_from_following: "new_post_from_following"
  }.freeze

  # Instance methods
  def mark_as_read!
    update(read: true)
  end

  def mark_as_read?
    read?
  end

  # Class methods
  def self.create_notification!(user:, actor:, notifiable:, notification_type:, params: {})
    create!(
      user: user,
      actor: actor,
      notifiable: notifiable,
      notification_type: notification_type,
      params: params.to_json
    )
  end

  # Get notification message based on type
  def message
    case notification_type
    when TYPES[:comment_on_post]
      "#{actor&.username} commented on your post \"#{notifiable.title}\""
    when TYPES[:reply_to_comment]
      "#{actor&.username} replied to your comment"
    when TYPES[:user_followed_you]
      "#{actor&.username} started following you"
    when TYPES[:new_post_from_following]
      "#{actor&.username} published a new post: \"#{notifiable.title}\""
    else
      "You have a new notification"
    end
  end

  # Get notification icon based on type
  def icon
    case notification_type
    when TYPES[:comment_on_post], TYPES[:reply_to_comment]
      "bi-chat-left-text"
    when TYPES[:user_followed_you]
      "bi-person-plus"
    when TYPES[:new_post_from_following]
      "bi-journal-text"
    else
      "bi-bell"
    end
  end

  # Get notification link based on type
  def link
    case notification_type
    when TYPES[:comment_on_post], TYPES[:new_post_from_following]
      notifiable.is_a?(Post) ? Rails.application.routes.url_helpers.post_path(notifiable) : nil
    when TYPES[:reply_to_comment]
      comment = notifiable
      Rails.application.routes.url_helpers.post_path(comment.commentable, anchor: "comment-#{comment.id}")
    when TYPES[:user_followed_you]
      Rails.application.routes.url_helpers.user_path(actor)
    else
      nil
    end
  end

  # Parse params
  def parsed_params
    params.present? ? JSON.parse(params) : {}
  end
end
