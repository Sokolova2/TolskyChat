# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  after_action :set_user_cookie, if: :user_signed_in?

  private

  def set_user_cookie
    cookies.encrypted[:user_id] = current_user.id
  end
end
