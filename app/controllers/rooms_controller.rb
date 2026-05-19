# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms, only: %i[index show public_search]
  before_action :set_room, only: %i[show update destroy]
  before_action :ensure_room_access!, only: :show
  before_action :ensure_room_owner!, only: %i[update destroy]

  def index
    conversation_set
    personal_chat_set
  end

  def show
    @caller = @room.messages.first&.user

    @message = Message.new

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
    @rooms = Room
             .joins(:participants)
             .where(participants: { user_id: current_user.id })
             .where(deleted_at: nil)
             .distinct
  end

  def set_room
    @room = Room.find(params.expect(:id))
  end

  def ensure_room_owner!
    participant = @room.participants.find_by(user_id: current_user.id)
    return if @room.is_a?(PersonalChat) && participant.present?

    return if participant&.owner?

    redirect_to rooms_path, alert: 'Only owner can delete room'
  end

  def ensure_room_access!
    return unless @room.is_private?
    return if @room.participants.exists?(user_id: current_user.id)

    redirect_to rooms_path, alert: 'You do not have access to this private room'
  end
end
