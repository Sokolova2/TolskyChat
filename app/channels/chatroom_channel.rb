class ChatroomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ChatroomChannel"
    ActionCable.server.broadcast(
    "ChatroomChannel",
    "Channel is subscribed"
    )
  end

  def unsubscribed
    stop_all_streams
  end
end
