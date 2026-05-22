class UnreadNotificationsDigestJob
  include Sidekiq::Job

  DIGEST_DELAY = 1.hour
  WINDOW = 15.minutes

  def perform(*args)
    upper_bound = DIGEST_DELAY.ago
    lower_bound = (DIGEST_DELAY + WINDOW).ago

    Notification
      .where(read: false)
      .where(created_at: lower_bound...upper_bound)
      .includes(:receiver)
      .group_by(&:receiver)
      .each do |user, notifications|
        next if user.blank? || user.email.blank?

        NotificationMailer.unread_digest(user, notifications).deliver_now()
    end
  end
end
