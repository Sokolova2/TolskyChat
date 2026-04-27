# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms, only: %i[index show]
  before_action :set_room, only: :destroy

  def index
    conversation_set
    personal_chat_set
  end

  def show
    @room = Room.find(params[:id])
    @message = Message.new

    if @room.is_a?(Conversation)
      @participants = @room.participants.order(role: :desc)
    elsif @room.is_a?(PersonalChat)
      @participants = @room.participants
    end
  end

  def destroy
    @room.destroy

    redirect_to rooms_path
  end

  private

  def conversation_set
    @conversations = Conversation
                       .joins(:participants)
                       .where(participants: { user_id: current_user.id })
                       .order(:created_at)

    @current_conversation = @conversations.first
  end

  def personal_chat_set
    @personal_chats = PersonalChat
                        .joins(:participants)
                        .where(participants: { user_id: current_user.id })
                        .order(:created_at)
  end

  def set_rooms
    @rooms = Room
    .joins(:participants)
    .where(participants: { user_id: current_user.id })
    .distinct
  end

  def set_room
    @room = Room.find(params[:id])
  end
end
