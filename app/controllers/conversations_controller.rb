# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :set_conversations, only: %i[index]

  def index; end

  def new
    @conversation_new = Conversation.new
    @conversation_new.participants.build
  end

  def create
    @conversation_new = RoomService.new(conversation_params, current_user).call

    if @conversation_new.save
      BroadcastRoomService.new(@conversation_new).broadcast_room
      redirect_to room_path(@conversation_new)
    else
      redirect_to new_conversation_path, alert: @conversation_new.errors.full_messages.to_sentence
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:name, :is_private, :deleted_at, participants_attributes: [:user_id, :role])
  end

  def set_conversations
    @conversations = current_user.rooms
  end
end
