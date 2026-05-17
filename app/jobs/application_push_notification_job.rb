class ApplicationPushNotificationJob < ActionPushNative::NotificationJob
  self.log_arguments = true

  self.report_job_retries = true
end
