# frozen_string_literal: true

class NotificationServices
  def initialize(notification:, sender_id:, receiver_id:, contact_id:, actor_login:)
    @notification = notification
    @sender_id = sender_id
    @receiver_id = receiver_id
    @contact_id = contact_id
    @actor_login = actor_login
  end

  def call
    user = User.find(@receiver_id)
    @notification.destroy

    Notification.create!(
      sender_id: @sender_id,
      receiver_id: @receiver_id,
      contact_id: @contact_id,
      content: "The user #{@actor_login} approved your request"
    )

    user
  end
end
