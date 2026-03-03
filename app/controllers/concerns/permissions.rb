# Permission module for moderator and admin access
module Permissions
  extend ActiveSupport::Concern

  included do
    helper_method :can_moderate?, :can_edit_post?, :can_delete_post?, :can_edit_comment?, :can_delete_comment?
  end

  private

  # Check if current user can moderate content
  def can_moderate?
    user_signed_in? && (current_user.admin? || current_user.moderator?)
  end

  # Check if user can edit a post
  def can_edit_post?(post)
    return false unless user_signed_in?
    current_user.admin? || current_user.moderator? || post.user_id == current_user.id
  end

  # Check if user can delete a post
  def can_delete_post?(post)
    can_edit_post?(post)
  end

  # Check if user can edit a comment
  def can_edit_comment?(comment)
    return false unless user_signed_in?
    current_user.admin? || current_user.moderator? || comment.user_id == current_user.id
  end

  # Check if user can delete a comment
  def can_delete_comment?(comment)
    can_edit_comment?(comment)
  end

  # Authorize user for post actions
  def authorize_post_access!(post)
    return if can_edit_post?(post)
    redirect_to posts_path, alert: "You are not authorized to perform this action."
  end

  # Authorize user for comment actions
  def authorize_comment_access!(comment)
    return if can_edit_comment?(comment)
    redirect_to comment.commentable, alert: "You are not authorized to perform this action."
  end
end
