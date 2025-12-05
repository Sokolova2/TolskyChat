class UsersController < ApplicationController
  def index
    @users = User.search(params[:search])
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    current_user.update(deleted_at: Time.current)
    redirect_to conversations_path
  end
end
