# frozen_string_literal: true

class ApplicationController < ActionController::Base
  after_action :set_user_cookie, if: :user_signed_in?
  layout :resolve_layout

  private

  def set_user_cookie
    cookies.encrypted[:user_id] = current_user.id
  end

  def resolve_layout
    turbo_frame_request? ? false : "application"
  end
end
