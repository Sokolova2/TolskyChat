# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rooms, only: %i[index show public_search]
  before_action :set_room, only: %i[update destroy]

  def index
    conversation_set
    personal_chat_set
  end

  def show
    @room = Room.find(params[:id])
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
      redirect_to rooms_path
    elsif @room.deleted_at.present?
      @room.update(deleted_at: nil)
      redirect_to rooms_path
    else
      redirect_to rooms_path, alert: @room.errors.full_messages
    end
  end

  def destroy
    @room.destroy

    redirect_to rooms_path
  end

  def archive
    @rooms_archived = Room.where.not(deleted_at: nil)
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
    @room = Room.find(params[:id])
  end
end
