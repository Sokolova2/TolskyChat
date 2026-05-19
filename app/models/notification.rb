# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :contact, optional: true

  after_create_commit :broadcast_counter
  after_create_commit :send_web_push

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

  def send_web_push
    vapid = Rails.application.credentials.dig(Rails.env.to_sym, :vapid)

    payload = {
      title: sender.login,
      body: content.to_s,
      notification_id: id
    }

    receiver.push_subscriptions.find_each do |sub|
      WebPush.payload_send(
        message: payload.to_json,
        endpoint: sub.endpoint,
        p256dh: sub.p256dh_key,
        auth: sub.auth_key,
        vapid: {
          subject: "mailto:you@example.com",
          public_key: ENV.fetch('VAPID_PUBLIC_KEY'),
          private_key: ENV.fetch('VAPID_PRIVATE_KEY')
        }
      )
    rescue => e
      Rails.logger.error("[WEBPUSH] #{e.class}: #{e.message}")
      raise if Rails.env.development?
    end
  end
end
