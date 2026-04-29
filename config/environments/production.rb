# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.enable_reloading = false

  config.eager_load = true

  config.consider_all_requests_local = false

  config.active_storage.service = :local

  config.action_controller.perform_caching = true

  config.public_file_server.headers = { 'cache-control' => "public, max-age=#{1.year.to_i}" }

  config.log_tags = [:request_id]
  config.logger   = ActiveSupport::TaggedLogging.logger($stdout)

  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  config.silence_healthcheck_path = '/up'

  config.active_support.report_deprecations = false

  config.cache_store = :memory_store

  config.active_job.queue_adapter = :async

  config.action_mailer.default_url_options = { host: 'example.com' }

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'gmail.com',
    user_name: ENV.fetch('USER_MAIL', nil),
    password: ENV.fetch('MAIL_PASSWORD', nil),
    authentication: 'plain',
    enable_starttls_auto: true
  }

  config.i18n.fallbacks = true

  config.active_record.dump_schema_after_migration = false

  config.active_record.attributes_for_inspect = [:id]
end
