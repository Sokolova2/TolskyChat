# frozen_string_literal: true

redis_url = ENV.fetch("REDIS_URL")

sidekiq_redis_config = {
  url: redis_url,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}

Sidekiq.configure_server do |config|
  config.redis = sidekiq_redis_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_redis_config
end