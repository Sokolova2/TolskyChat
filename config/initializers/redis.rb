redis_url = ENV["REDIS_URL"]

if redis_url.present?
  uri = URI.parse(redis_url)

  REDIS = Redis.new(
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  )
end