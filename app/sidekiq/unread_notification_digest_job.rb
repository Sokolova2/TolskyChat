class UnreadNotificationDigestJob
  include Sidekiq::Job

  def perform(*args)
    time = 1.hour.ago

    Notification
      .where(read: false)
      .where('created_at <= ?', time)
      .includes(:receiver)
      .group_by(&:receiver)
      .each do |user, notifications|
        next if user.blank? || user.email.blank?

        NotificationMailer.unread_digest(user, notifications).deliver_now()
    end
  end
end
