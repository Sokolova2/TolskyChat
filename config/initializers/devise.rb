# frozen_string_literal: true

Devise.setup do |config|
  # config.secret_key = '3484bdc8ae76ca2cb212dd279b60cf15e8da14deac06b5b2f11efbcce960f135ef0cfe583edae58cef3c88f1f713f8a3734fbf3c248297270c0efff407ed7900'

  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  require 'devise/orm/active_record'

  config.case_insensitive_keys = [:email]

  config.strip_whitespace_keys = [:email]

  # config.params_authenticatable = true

  # config.http_authenticatable = false

  # config.http_authenticatable_on_xhr = true

  # config.http_authentication_realm = 'Application'

  # config.paranoid = true

  config.skip_session_storage = [:http_auth]

  # config.clean_up_csrf_token_on_authentication = true

  # config.reload_routes = true

  config.stretches = Rails.env.test? ? 1 : 12

  config.reconfirmable = true

  config.expire_all_remember_me_on_sign_out = true

  config.password_length = 6..128

  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours

  config.sign_out_via = :delete

  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  config.omniauth :google_oauth2,
                  ENV.fetch('GOOGLE_CLIENT_ID', nil),
                  ENV.fetch('GOOGLE_CLIENT_SECRET', nil)
end
