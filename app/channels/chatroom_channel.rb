# frozen_string_literal: true

class ChatroomChannel < ApplicationCable::Channel
  def subscribed
    @room = Room.find(params[:room_id])

    stream_for @room
    set_present(true)
    mark_room_as_read!
  end

  def unsubscribed
    set_present(false)
    stop_all_streams
  end

  def mark_read(_data = {})
    set_present(true)
    mark_room_as_read!
  end

  private

  def presence_key
    "room:#{@room.id}:present_users"
  end

  def set_present(value)
    return unless defined?(REDIS) && REDIS

    if value
      REDIS.sadd(presence_key, current_user.id)
      REDIS.expire(presence_key, 120)
    else
      REDIS.srem(presence_key, current_user.id)
    end
  end

  def mark_room_as_read!
    unread = @room.messages.where(read: false).where.not(user_id: current_user.id)
    ids = unread.pluck(:id)
    return if ids.empty?

    unread.update_all(read: true, updated_at: Time.current)

    ChatroomChannel.broadcast_to(
      @room,
      action: 'read_update',
      message_ids: ids
    )
  end
end
