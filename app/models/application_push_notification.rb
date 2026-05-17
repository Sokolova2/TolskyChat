# frozen_string_literal: true

class ApplicationPushNotification < ActionPushNative::Notification
  queue_as :realtime

  self.enabled = Rails.env.production?

  before_delivery do |notification|
    throw :abort if Notification.find(notification.context[:notification_id]).expired?
  end
end
