class AppearancesChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "[AppearancesChannel] subscribed"
    stream_from 'AppearancesChannel'
  end

  def unsubscribed
    #Any cleanup needed when channel is unsubscribed
  end
end
