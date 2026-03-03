class ApplicationController < ActionController::Base
  include Permissions

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Set locale from session or params
  before_action :set_locale

  private

  def set_locale
    # Check for locale in params, session, cookie, then use default
    locale = params[:locale] || session[:locale] || cookies[:locale] || I18n.default_locale

    # Validate that the locale is available
    if I18n.available_locales.map(&:to_s).include?(locale.to_s)
      I18n.locale = locale
      session[:locale] = locale
    else
      I18n.locale = I18n.default_locale
    end
  end

  def mark_notifications_as_read
    current_user.notifications.unread.update_all(read: true) if request.get?
  end
end
