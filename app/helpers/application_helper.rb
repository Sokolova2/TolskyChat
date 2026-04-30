# frozen_string_literal: true

module ApplicationHelper
  def voice_ice_servers
    servers = []

    stun_urls = ENV.fetch('STUN_URLS', '')
                   .split(',')
                   .map(&:strip)
                   .reject(&:blank?)
    stun_urls = [ENV.fetch('STUN_SERVER', 'stun:stun.l.google.com:19302')] if stun_urls.empty?
    servers << { urls: stun_urls.one? ? stun_urls.first : stun_urls }

    turn_urls = ENV.fetch('TURN_URLS', '')
                   .split(',')
                   .map(&:strip)
                   .reject(&:blank?)
    if turn_urls.empty?
      single_turn_url = ENV.fetch('TURN_URL', '').strip
      if single_turn_url.present?
        turn_urls = [single_turn_url]
      else
        turn_host = ENV.fetch('TURN_HOST', '').strip
        if turn_host.present?
          turn_urls = [
            "turn:#{turn_host}:3478?transport=udp",
            "turn:#{turn_host}:3478?transport=tcp",
            "turns:#{turn_host}:5349?transport=tcp"
          ]
        end
      end
    end

    turn_username = ENV['TURN_USERNAME'].presence || ENV['COTURN_USERNAME'].presence
    turn_credential = ENV['TURN_PASSWORD'].presence ||
                      ENV['TURN_CREDENTIAL'].presence ||
                      ENV['COTURN_PASSWORD'].presence

    if turn_urls.any? && turn_username.present? && turn_credential.present?
      servers << {
        urls: turn_urls.one? ? turn_urls.first : turn_urls,
        username: turn_username,
        credential: turn_credential
      }
    end

    servers
  end
end
