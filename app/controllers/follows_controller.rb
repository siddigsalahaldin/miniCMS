class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:follow, :unfollow, :toggle]

  # GET /users/:user_id/followers
  def followers
    @user = User.find(params[:user_id])
    @followers = @user.followers.includes(:follower).recent
  end

  # GET /users/:user_id/followings
  def followings
    @user = User.find(params[:user_id])
    @followings = @user.followings.includes(:followed).recent
  end

  # POST /users/:user_id/follow
  def follow
    if current_user == @user
      redirect_to @user, alert: "You cannot follow yourself."
      return
    end

    current_user.follow!(@user)
    
    # Create notification for the followed user
    Notification.create_notification!(
      user: @user,
      actor: current_user,
      notifiable: @user,
      notification_type: Notification::TYPES[:user_followed_you]
    )
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user, notice: "You are now following #{@user.username}." }
      format.json { render :show, status: :ok }
    end
  end

  # DELETE /users/:user_id/unfollow
  def unfollow
    current_user.unfollow!(@user)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user, notice: "You have unfollowed #{@user.username}." }
      format.json { render :show, status: :ok }
    end
  end

  # POST /users/:user_id/toggle_follow
  def toggle
    if current_user == @user
      redirect_to @user, alert: "You cannot follow yourself."
      return
    end

    following = current_user.toggle_follow(@user)
    
    # Create notification when following (not when unfollowing)
    if following
      Notification.create_notification!(
        user: @user,
        actor: current_user,
        notifiable: @user,
        notification_type: Notification::TYPES[:user_followed_you]
      )
    end
    
    respond_to do |format|
      format.turbo_stream
      format.html do
        notice = following ? "You are now following #{@user.username}." : "You have unfollowed #{@user.username}."
        redirect_to @user, notice: notice
      end
      format.json { render :show, status: :ok }
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
