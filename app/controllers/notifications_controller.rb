class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # GET /notifications
  def index
    # Mark all notifications as read when viewing the notifications page
    current_user.notifications.unread.update_all(read: true)
    
    @notifications = current_user.notifications
                                  .includes(:actor, :notifiable)
                                  .recent
                                  .limit(50)
    @unread_count = current_user.unread_notifications_count
  end

  # PATCH /notifications/:id/read
  def read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: notifications_path) }
    end
  end

  # PATCH /notifications/read_all
  def read_all
    current_user.notifications.unread.update_all(read: true)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path, notice: "All notifications marked as read." }
    end
  end

  # POST /notifications/mark_read
  def mark_read
    current_user.notifications.unread.update_all(read: true)

    respond_to do |format|
      format.turbo_stream
    end
  end

  # DELETE /notifications/:id
  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path, notice: "Notification deleted." }
    end
  end
end
