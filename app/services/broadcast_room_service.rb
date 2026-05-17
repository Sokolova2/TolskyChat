# frozen_string_literal: true

class BroadcastRoomService
  def initialize(room)
    @room = room
  end

  def broadcast_room
    return broadcast_delete if @room.deleted_at.present?

    participants_with_users.find_each do |participant|
      broadcast_upsert(participant.user, render_room_html(participant.user))
    end
  end

  def broadcast_delete
    participants_with_users.map(&:user).each { |user| broadcast_delete_for(user) }
  end

  private

  def participants_with_users
    @room.participants.includes(:user)
  end

  def render_room_html(user)
    ApplicationController.render(
      partial: 'navbar/rooms',
      locals: { room: @room, current_user: user }
    )
  end

  def broadcast_upsert(user, html)
    RoomChannel.broadcast_to(
      user,
      action: 'upsert',
      room_id: @room.id,
      html: html
    )
  end

  def broadcast_delete_for(user)
    RoomChannel.broadcast_to(
      user,
      action: 'delete',
      room_id: @room.id
    )
  end
end
