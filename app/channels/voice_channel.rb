# frozen_string_literal: true

class VoiceChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def signal(data)
    receiver = User.find_by(id: data['receiver_id'])
    return unless receiver

    VoiceChannel.broadcast_to(receiver, data)
  end
end
