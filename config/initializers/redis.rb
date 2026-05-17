# frozen_string_literal: true

redis_url = ENV.fetch('REDIS_URL', nil)

if redis_url.present?
  URI.parse(redis_url)

  REDIS = Redis.new(
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  )
end
