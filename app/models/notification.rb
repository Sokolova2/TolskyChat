# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :contact, optional: true

  after_create_commit :broadcast_counter

  def broadcast_counter
    NotificationsChannel.broadcast_to(
      receiver,
      {
        html: ApplicationController.renderer.render(
          partial: 'notifications/notification',
          locals: { notification: self }
        ),
        count: receiver.receiver_notifications.where(read: false).count
      }
    )
  end
end
