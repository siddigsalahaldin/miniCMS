# Concern for models that can generate notifications
module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :notifiable, dependent: :destroy
  end

  # Create a notification for the owner of this notifiable
  def notify_owner!(actor:, notification_type:, params: {})
    return unless respond_to?(:user) && user

    Notification.create_notification!(
      user: user,
      actor: actor,
      notifiable: self,
      notification_type: notification_type,
      params: params
    )
  end
end
