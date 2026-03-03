class Users::RegistrationsController < Devise::RegistrationsController
  # Add strong parameters for Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Override the update method to handle avatar upload
  def update
    # Handle avatar removal
    if params[:user][:remove_avatar] == '1'
      current_user.avatar.purge if current_user.avatar.attached?
    end

    # Update password if provided
    if update_params[:password].blank?
      update_params.delete(:password)
      update_params.delete(:password_confirmation)
    end

    super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :bio, :avatar])
  end

  # Permit additional fields for sign up
  def sign_up_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end

  # Permit additional fields for account update
  def account_update_params
    params.require(:user).permit(:email, :username, :bio, :avatar, :password, :password_confirmation, :current_password, :remove_avatar)
  end

  private

  def update_params
    account_update_params
  end
end
