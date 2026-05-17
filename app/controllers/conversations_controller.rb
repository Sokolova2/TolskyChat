# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :set_conversations, only: :index
  before_action :set_conversation, only: :update
  before_action :ensure_owner_or_moderator!, only: :update

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

  def update
    if @conversation.update(conversation_params)
      BroadcastRoomService.new(@conversation).broadcast_room
      redirect_to room_path(@conversation)
    else
      redirect_to room_path(@conversation), alert: @conversation.errors.full_messages.to_sentence
    end
  end

  private

  def conversation_params
    params.expect(conversation: [:name, :is_private, :deleted_at, { participants_attributes: %i[user_id role] }])
  end

  def set_conversations
    @conversations = current_user.rooms
  end

  def set_conversation
    @conversation = Conversation.find(params.expect(:id))
  end

  def ensure_owner_or_moderator!
    participant = @conversation.participants.find_by(user_id: current_user.id)

    return if participant&.owner? || participant&.moderator?

    redirect_to rooms_path, alert: 'Only owner or moderator can update conversation'
  end
end
