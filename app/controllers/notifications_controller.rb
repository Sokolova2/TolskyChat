# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[update destroy reject]
  before_action :set_contact, only: %i[update destroy reject]

  def index
    @notifications = current_user.receiver_notifications.order(created_at: :desc)
    @notifications.find_each { |n| n.update!(read: true) }

    NotificationsChannel.broadcast_to(
      current_user,
      { count: 0 }
    )
  end

  def update
    @user = @contact.update(approved: true) ? approve_contact_and_notify : sender_user
    respond_notification_update
  end

  def reject
    sender_id = @contact.sender_id

    if @contact.destroy
      Notification.create(
        sender_id: current_user.id,
        receiver_id: sender_id,
        contact_id: nil,
        content: "The user #{current_user.login} rejected your request"
      )
    end

    redirect_to notifications_path
  end

  def destroy
    @notification.destroy
    redirect_to notifications_path
  end

  private

  def approve_contact_and_notify
    NotificationServices.new(
      notification: @notification,
      sender_id: current_user.id,
      receiver_id: @contact.sender_id,
      contact_id: @contact.id,
      actor_login: current_user.login
    ).call
  end

  def sender_user
    User.find(@contact.sender_id)
  end

  def respond_notification_update
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end

  def set_notification
    @notification = Notification.find(params.expect[:id])
  end

  def set_contact
    @contact = @notification.contact
  end
end
