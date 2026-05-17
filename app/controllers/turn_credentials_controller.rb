# frozen_string_literal: true

require 'net/http'
require 'json'

class TurnCredentialsController < ApplicationController
  before_action :authenticate_user!

  def show
    sid = ENV['TWILIO_ACCOUNT_SID'].presence
    token = ENV['TWILIO_AUTH_TOKEN'].presence

    if sid.blank? || token.blank?
      render json: { error: 'Twilio credentials are not configured' }, status: :unprocessable_content
      return
    end

    uri = URI("https://api.twilio.com/2010-04-01/Accounts/#{sid}/Tokens.json")
    req = Net::HTTP::Post.new(uri)
    req.basic_auth(sid, token)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    res = http.request(req)

    unless res.is_a?(Net::HTTPSuccess)
      render json: { error: 'Failed to fetch TURN credentials from Twilio' }, status: :bad_gateway
      return
    end

    body = JSON.parse(res.body)
    ice_servers = Array(body['ice_servers']).map do |server|
      next if server['urls'].blank? && server['url'].blank?

      {
        urls: server['urls'] || server['url'],
        username: server['username'],
        credential: server['credential'] || body['password']
      }.compact
    end.compact

    render json: { ice_servers: ice_servers }
  rescue StandardError => e
    Rails.logger.error("[TURN] #{e.class}: #{e.message}")
    render json: { error: 'TURN credentials error' }, status: :internal_server_error
  end
end
