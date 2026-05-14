# frozen_string_literal: true

class PersonalChatsController < ApplicationController
  before_action :set_chats, only: %i[index]

  def index; end

  def create
    second_user = User.find(personal_chat_params[:second_user_id])
    existing_chat = PersonalChat
                      .joins(:participants)
                      .where(participants: { user_id: [current_user.id, second_user.id] })
                      .group('rooms.id')
                      .having('COUNT(DISTINCT participants.user_id) = 2')
                      .first

    if existing_chat.present?
      redirect_to room_path(existing_chat)
      return
    end

    @personal_chat_new = RoomService.new({}, current_user).call_chat(second_user)

    if @personal_chat_new.save
      BroadcastRoomService.new(@personal_chat_new).broadcast_room
      redirect_to room_path(@personal_chat_new)
    else
      redirect_to room_path, alert: @personal_chat_new.errors.full_messages.to_sentence
    end
  end

  private

  def personal_chat_params
    params.require(:personal_chat).permit(:name, :is_private, :deleted_at, :second_user_id, participants_attributes: [:user_id, :role])
  end

  def set_chats
    @personal_chats = current_user.rooms
  end
end
