class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Include search functionality
  include Searchable

  # Include notifiable for notifications
  include Notifiable

  # Relationships
  belongs_to :user
  has_rich_text :body

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_by_users, through: :favorites, source: :user
  has_many :reactions, as: :reactable, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  # Scopes
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :with_user, -> { includes(:user) }

  # Callbacks
  before_save :ensure_slug_uniqueness
  after_create :notify_followers

  # Instance methods
  def published?
    published
  end

  def favorite_by!(user)
    favorites.find_or_create_by!(user: user)
  end

  def unfavorite_by!(user)
    favorites.find_by(user: user)&.destroy
  end

  def favorited_by?(user)
    favorites.exists?(user: user)
  end

  def reaction_count_by_type(reaction_type)
    reactions.where(reaction_type: reaction_type).count
  end

  def total_reactions_count
    reactions.count
  end

  # Class methods for N+1 optimization
  class << self
    def with_associations
      includes(:user, :rich_text_body, comments: :user, reactions: :user)
    end

    def with_reaction_counts
      includes(:user).left_joins(:reactions).group(:id)
    end

    # Search in title and rich text body
    def search_with_body(query)
      return none if query.blank?
      
      # Search in title
      title_matches = where("title LIKE ?", "%#{query}%")
      
      # Search in rich text body (Action Text)
      body_post_ids = joins(:rich_text_body)
        .where("action_text_rich_texts.body LIKE ?", "%#{query}%")
        .select(:id)
      
      # Combine results using IDs
      where(id: title_matches.select(:id))
        .or(where(id: body_post_ids))
        .distinct
    end
  end

  private

  def ensure_slug_uniqueness
    base_slug = slug.parameterize
    counter = 2
    original_slug = base_slug

    while Post.exists?(slug: base_slug) && Post.find_by(slug: base_slug)&.id != id
      base_slug = "#{original_slug}-#{counter}"
      counter += 1
    end

    self.slug = base_slug
  end

  def should_generate_new_friendly_id?
    title_changed? || slug.blank?
  end

  # Notify followers when a new post is published
  def notify_followers
    return unless published?

    # Get all users who follow this post's author
    follower_ids = user.followers.select(:follower_id)
    followers = User.where(id: follower_ids).where.not(id: user.id)

    followers.each do |follower|
      Notification.create_notification!(
        user: follower,
        actor: user,
        notifiable: self,
        notification_type: Notification::TYPES[:new_post_from_following],
        params: { post_title: title }
      )
    end
  end
end
