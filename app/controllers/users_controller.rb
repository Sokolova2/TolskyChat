# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.search(params[:search])
                 .where(deleted_at: nil)
                 .all_except(current_user)
  end

  def show
    @user = User.find(params.except[:id])
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

  def register_subscription
    subscription_json = params[:subscription]
    return head :bad_request if subscription_json.blank?

    subscription_params = JSON.parse(subscription_json)
    keys = subscription_params['keys'] || {}

    subscription = current_user.push_subscriptions.find_or_initialize_by(
      endpoint: subscription_params['endpoint']
    )
    subscription.assign_attributes(
      auth_key: keys['auth'],
      p256dh_key: keys['p256dh']
    )

    return head :ok if subscription.save

    render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
  rescue JSON::ParserError
    head :bad_request
  end
end
