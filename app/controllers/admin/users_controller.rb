module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy, :toggle_admin]
    
    def index
      case params[:filter]
      when 'admin'
        @users = User.where(role: 2).order(created_at: :desc).limit(100)
      when 'moderator'
        @users = User.where(role: 1).order(created_at: :desc).limit(100)
      else
        @users = User.order(created_at: :desc).limit(100)
      end
    end
    
    def show
    end
    
    def edit
    end
    
    def update
      # Convert role string to integer
      if user_params[:role].present?
        user_params[:role] = user_params[:role].to_i
      end
      
      # Remove password params if blank or empty string
      if user_params[:password].blank? || user_params[:password] == ""
        user_params.delete(:password)
        user_params.delete(:password_confirmation)
      end
      
      # Update user without password validation
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User was successfully updated. New role: #{@user.role_name}"
      else
        Rails.logger.error "Update failed! Errors: #{@user.errors.full_messages.inspect}"
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "User was successfully destroyed."
    end
    
    def toggle_admin
      @user.update(admin: !@user.admin)
      redirect_to admin_user_path(@user), notice: "User admin status was updated."
    end
    
    private
    
    def set_user
      @user = User.find(params[:id])
    end
    
    def user_params
      params.require(:user).permit(:email, :username, :bio, :role, :password, :password_confirmation)
    end
  end
end
