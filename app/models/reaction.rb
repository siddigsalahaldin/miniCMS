class Reaction < ApplicationRecord
  # Enum for reaction types
  enum :reaction_type, {
    like: 0,
    love: 1,
    celebrate: 2,
    support: 3,
    insightful: 4
  }

  # Relationships
  belongs_to :user
  belongs_to :reactable, polymorphic: true

  # Validations
  validates :user_id, uniqueness: { scope: [:reactable_type, :reactable_id], message: "has already reacted to this item" }
  validates :reaction_type, presence: true

  # Scopes
  scope :by_type, ->(type) { where(reaction_type: type) }
  scope :for_reactable, ->(reactable) { where(reactable: reactable) }
  scope :recent, -> { order(created_at: :desc) }

  # Class methods for N+1 optimization
  class << self
    def with_user
      includes(:user)
    end

    def counts_by_type_for(reactable)
      where(reactable: reactable)
        .group(:reaction_type)
        .count
    end

    def total_count_for(reactable)
      where(reactable: reactable).count
    end

    def user_reaction_for(reactable, user)
      find_by(reactable: reactable, user: user)
    end
  end

  # Instance methods
  def emoji
    case reaction_type
    when "like" then "👍"
    when "love" then "❤️"
    when "celebrate" then "🎉"
    when "support" then "💪"
    when "insightful" then "💡"
    end
  end

  def label
    reaction_type.humanize
  end
end
