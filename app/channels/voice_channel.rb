class VoiceChannel < ApplicationCable::Channel
  def subscribed
    stream_from current_user
  end

  def signal(data)
    receiver = User.find_by(id: data["receiver_id"])
    return unless receiver

    VoiceChannel.broadcast_to(receiver, data)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
