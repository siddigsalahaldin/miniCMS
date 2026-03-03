module Concerns
  module NPlusOnePrevention
    extend ActiveSupport::Concern

    # Common associations loading patterns to prevent N+1 queries

    module_function

    # Post associations for listing pages
    def post_listing_includes
      [:user, { rich_text_body: nil }]
    end

    # Post associations for show page
    def post_show_includes
      [:user, { rich_text_body: nil }, { comments: [:user, :parent] }, { reactions: :user }]
    end

    # Comment associations
    def comment_includes
      [:user, :parent, { replies: [:user] }, { reactions: :user }]
    end

    # User associations for profiles
    def user_profile_includes
      [{ posts: [:rich_text_body] }, :followers, :followings]
    end

    # Reaction counts with grouping
    def reaction_counts_for(posts)
      Reaction.where(reactable: posts)
              .group(:reactable_type, :reactable_id, :reaction_type)
              .count
    end
  end
end
