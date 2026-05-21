class UnreadMessagesReminderJob
  include Sidekiq::Job

  def perform(*args)
    time = 30.minutes.ago

    Message
      .where(read: false)
      .where('created_at <= ?', time)
      .includes(:room)
      .find_each do |message|

      room = message.room
      count = room.messages.where(read: false).where.not(user_id: message.user_id).count
      room.participants.where.not(user_id: message.user_id).find_each do |participant|
        Notification.create!(
          sender_id: message.user_id,
          receiver_id: participant.user_id,
          contact_id: nil,
          content: "In \"#{room.name}\", you have #{count} unread message(s) for more than 30 minutes."
        )
      end
    end
  end
end
