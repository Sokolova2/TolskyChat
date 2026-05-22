# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  after_action :set_user_cookie, if: :user_signed_in?

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_user_cookie
    cookies.encrypted[:user_id] = current_user.id
  end

  def user_not_authorized(exception)
    message =
      case exception.query
      when :destroy? then 'Only owner can delete room'
      when :update? then 'Only owner can edit room'
      when :archive? then 'Only owner can archive room'
      else 'You are not authorized to perform this action.'
      end

    redirect_to root_path, alert: message
  end
end
