# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :set_conversations, only: :index
  before_action :set_conversation, only: :update
  before_action :authorize_index! , only: :index
  before_action :authorize_new! , only: :new
  before_action :authorize_create! , only: :create
  before_action :authorize_update! , only: :update

  def index; end

  def new
    @conversation_new = Conversation.new
    @conversation_new.participants.build
  end

  def create
    @conversation_new = RoomService.new(current_user, conversation_params).call

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
    @conversations = policy_scope(Conversation)
  end

  def set_conversation
    @conversation = Conversation.find(params.expect(:id))
  end

  def authorize_index!
    authorize Conversation
  end

  def authorize_new!
    authorize Conversation
  end

  def authorize_create!
    authorize Conversation
  end

  def authorize_update!
    authorize @conversation
  end
end
