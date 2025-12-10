class AppearancesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "appearances_channel"
  end

  def unsubscribed
    #Any cleanup needed when channel is unsubscribed
  end
end
