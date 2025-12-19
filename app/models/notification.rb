# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :contact, optional: true

  after_create :broadcast_counter

  def broadcast_counter
    NotificationsChannel.broadcast_to(
      receiver,
      html: ApplicationController.render(
      partial: 'navbar/notifications',
      locals: { current_user: receiver }
      )
    )
  end
end
