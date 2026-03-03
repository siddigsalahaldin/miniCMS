class LocaleController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :set

  def set
    locale = params[:locale]
    
    # Validate that the locale is available
    if I18n.available_locales.map(&:to_s).include?(locale.to_s)
      session[:locale] = locale
      I18n.locale = locale
      # Store the locale in a cookie for persistence
      cookies[:locale] = { value: locale, expires: 1.year.from_now, path: '/' }
    end
    
    # Get the referrer or redirect to root
    referrer = request.referer
    if referrer && referrer.present?
      redirect_to referrer
    else
      redirect_to root_path
    end
  end
end
