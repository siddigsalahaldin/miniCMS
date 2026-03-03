module Admin
  class BaseController < ApplicationController
    layout 'admin'
    
    before_action :authenticate_admin_user!
    
    private
    
    def authenticate_admin_user!
      # Check if user is signed in and is an admin
      unless user_signed_in? && current_user.admin?
        redirect_to root_path, alert: "You are not authorized to access the admin panel."
      end
    end
    
    # Helper methods for admin
    helper_method :current_admin_user
    
    def current_admin_user
      current_user if user_signed_in? && current_user.admin?
    end
  end
end
