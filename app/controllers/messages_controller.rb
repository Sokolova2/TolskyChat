# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_room, only: :create
  before_action :set_room_from_params, only: :destroy

  def create
    @message = @room.messages.new(message_params.merge(user: current_user))

    return unless @message.save

    create_nofitication

    broadcast_message
  end

  def destroy
    message = @room.messages.find(params.expect(:id))
    return head :forbidden unless message.user == current_user

    message.destroy

    ChatroomChannel.broadcast_to(
      @room,
      action: 'delete',
      message_id: message.id
    )

    head :ok
  end

  private

  def set_room
    @room = Room.find(params.expect(:room_id))
  end

  def set_room_from_params
    @room = Room.find(params.expect(:room_id))
  end

  def message_params
    params.expect(message: %i[content room_id featured_image audio_file])
  end

  def broadcast_message
    ChatroomChannel.broadcast_to(
      @room,
      html: render_to_string(
        partial: 'messages/message',
        formats: [:html],
        locals: { message: @message }
      )
    )
  end

  def create_nofitication
    @rooms = Room.find(params.expect(:room_id))

    @rooms.participants.each do |participant|
      next if participant.user_id == current_user.id

      Notification.create(
        sender_id: current_user.id,
        receiver_id: participant.user_id,
        contact_id: nil,
        content: @message.content.to_plain_text
      )
    end
  end
end
