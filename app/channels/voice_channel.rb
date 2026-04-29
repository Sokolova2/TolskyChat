class VoiceChannel < ApplicationCable::Channel
  def subscribed
    reject unless params[:room_id].present?

    stream_from "voice_room_#{params[:room_id]}"
  end

  def signal(data)
    room_id = data["room_id"]

    return unless room_id.present?

    ActionCable.server.broadcast(
      "voice_room_#{room_id}",
      data
    )
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
