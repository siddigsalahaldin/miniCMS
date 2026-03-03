class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Skip password validation if password is not being changed
  def password_required?
    # Require password only when creating new user or changing password
    !persisted? || password.present? || password_confirmation.present?
  end

  # Validations
  validates :username, presence: true,
                       length: { minimum: 3, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "can only contain letters, numbers, and underscores" }
  validate :username_uniqueness

  # Relationships - Following system (self-join)
  has_many :followings, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy
  has_many :followers, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy

  has_many :followed_users, through: :followings, source: :followed
  has_many :followers_list, through: :followers, source: :follower

  # Posts and Comments
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_posts, through: :favorites, source: :post
  has_many :reactions, dependent: :destroy

  # Notifications
  has_many :notifications, dependent: :destroy
  has_many :created_notifications, class_name: "Notification", foreign_key: :actor_id, dependent: :nullify

  # Avatar attachment (Active Storage)
  has_one_attached :avatar, dependent: :destroy

  # Helper method to check if user has avatar
  def has_avatar?
    avatar.attached? && avatar.persisted?
  end

  # Helper method for unread notifications count
  def unread_notifications_count
    notifications.unread.count
  end

  # Helper method for recent unread notifications (with eager loading)
  def recent_unread_notifications(limit = 5)
    notifications.includes(:actor, :notifiable).unread.recent.limit(limit)
  end

  # Role - use integer column directly without enum for Rails 8.1 compatibility
  # Roles: 0 = member, 1 = moderator, 2 = admin
  
  # Helper methods for role checking
  def admin?
    role.to_i == 2
  end
  
  def moderator?
    role.to_i == 1
  end
  
  def member?
    role.to_i == 0 || role.nil?
  end
  
  # Get role as string
  def role_name
    case role.to_i
    when 2 then "admin"
    when 1 then "moderator"
    else "member"
    end
  end

  # Custom validation for username uniqueness (excludes current user)
  def username_uniqueness
    existing_user = User.where('LOWER(username) = LOWER(?) AND id != ?', username, id).first
    if existing_user
      errors.add(:username, 'has already been taken')
    end
  end

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { left_joins(:followers).group(:id).order('COUNT(follows.id) DESC') }
  scope :admins, -> { where(role: 2) }
  scope :moderators, -> { where(role: 1) }
  scope :members, -> { where(role: 0).or(where(role: nil)) }

  # Instance methods
  def follows?(other_user)
    followings.exists?(followed_id: other_user.id)
  end

  def follow!(other_user)
    followings.create!(followed: other_user)
  end

  def unfollow!(other_user)
    followings.find_by(followed: other_user)&.destroy
  end

  def toggle_follow(other_user)
    if follows?(other_user)
      unfollow!(other_user)
      false
    else
      follow!(other_user)
      true
    end
  end

  def favorite?(post)
    favorites.exists?(post_id: post.id)
  end

  def reactable?(reactable)
    reactions.exists?(reactable: reactable)
  end
end
