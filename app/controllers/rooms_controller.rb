# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms, only: %i[index show public_search]
  before_action :set_room, only: %i[show update destroy]
  before_action :authorize_room!, only: %i[show update destroy]
  before_action :authorize_archive!, only: :archive
  before_action :authorize_public_search!, only: :public_search

  def index
    conversation_set
    personal_chat_set
  end

  def show
    @caller = @room.messages.first&.user

    @message = Message.new

    unread_scope = @room.messages.where(read: false).where.not(user_id: current_user.id)
    read_message_ids = unread_scope.pluck(:id)
    unread_scope.update_all(read: true, updated_at: Time.current)

    if read_message_ids.any?
      ChatroomChannel.broadcast_to(
        @room,
        action: 'read_update',
        message_ids: read_message_ids
      )
    end

    if @room.is_a?(Conversation)
      @participants = @room.participants.order(role: :desc)
    elsif @room.is_a?(PersonalChat)
      @participants = @room.participants
    end
  end

  def update
    if @room.deleted_at.blank?
      @room.update(deleted_at: Time.current)
    else
      @room.update(deleted_at: nil)
    end

    BroadcastRoomService.new(@room).broadcast_room

    redirect_to rooms_path, alert: @room.errors.full_messages
  end

  def destroy
    BroadcastRoomService.new(@room).broadcast_delete

    @room.destroy

    redirect_to rooms_path
  end

  def archive
    @rooms_archived = Room.joins(:participants)
                          .where(participants: { user_id: current_user.id, role: :owner })
                          .where.not(deleted_at: nil)
                          .distinct
  end

  def public_search
    @public_rooms = SearchService.new(
      Room.public_rooms.where(deleted_at: nil)
    ).search_room(params[:search]).order(:name)
  end

  private

  def conversation_set
    @conversations = Conversation
                     .joins(:participants)
                     .where(participants: { user_id: current_user.id })
                     .where(deleted_at: nil)
                     .order(:created_at)
  end

  def personal_chat_set
    @personal_chats = PersonalChat
                      .joins(:participants)
                      .where(participants: { user_id: current_user.id })
                      .where(deleted_at: nil)
                      .order(:created_at)
  end

  def set_rooms
    @rooms = policy_scope(Room)
  end

  def set_room
    @room = Room.find(params.expect(:id))
  end

  def authorize_room!
    authorize @room
  end

  def authorize_archive!
    authorize Room, :archive?
  end

  def authorize_public_search!
    authorize Room, :public_search?
  end
end
