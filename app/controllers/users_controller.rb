# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.search(params[:search])
                 .where(deleted_at: nil)
                 .all_except(current_user)
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    if current_user.deleted_at.present?
      flash[:notice] = 'Your account is unarchived'
      current_user.update(deleted_at: nil)
    else
      flash[:alert] = 'Your account is archived'
      current_user.update(deleted_at: Time.current)
    end

    redirect_to edit_user_path(current_user)
  end
end
