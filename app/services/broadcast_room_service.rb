# frozen_string_literal: true

class BroadcastRoomService
  def initialize(room)
    @room = room
  end

  def broadcast_room
    if @room.deleted_at.present?
      return broadcast_delete
    end

    @room.participants.includes(:user).each do |participant|
      html = ApplicationController.render(
        partial: 'navbar/rooms',
        locals: {
          room: @room,
          current_user: participant.user
        }
      )

      RoomChannel.broadcast_to(
        participant.user,
        action: 'upsert',
        room_id: @room.id,
        html: html
      )
    end
  end

  def broadcast_delete
    users = @room.participants.includes(:user).map(&:user)

    users.each do |user|
      RoomChannel.broadcast_to(
        user,
        action: 'delete',
        room_id: @room.id
      )
    end
  end
end