class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_user, only: [:show]

  # GET /users
  # GET /users.json
  def index
    @users = User.includes(:followers, :followings)
                 .order(created_at: :desc)
                 .limit(50)
  end

  # GET /users/:id
  # GET /users/:id.json
  def show
    @posts = @user.posts.published.recent.limit(10)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
