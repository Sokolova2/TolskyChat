# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :set_notification, only: %i[update destroy reject]
  before_action :set_contact, only: %i[update destroy reject]
  def index
    @notifications = Notification.where(receiver_id: current_user.id)
  end

  def update
    if @contact.update(approved: true)
      @notification.destroy
      Notification.create(
        sender_id: current_user.id,
        receiver_id: @contact.sender_id,
        contact_id: @contact.id,
        content: "The user #{@notification.receiver.login} approved your request"
      )
    end

    redirect_to notifications_path
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

  def set_notification
    @notification = Notification.find(params[:id])
  end

  def set_contact
    @contact = @notification.contact
  end
end
