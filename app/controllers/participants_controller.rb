# frozen_string_literal: true

class ParticipantsController < ApplicationController
  before_action :set_room, only: %i[create update destroy]
  before_action :set_participant, only: %i[update destroy]
  before_action :ensure_can_invite!, only: :create
  before_action :ensure_room_owner!, only: :update
  before_action :ensure_owner_or_moderator!, only: :destroy
  before_action :self_removal!, only: :destroy
  before_action :user_ids, only: :create

  def create
    result = ParticipantsCreateService.new(
      room: @room,
      current_user: current_user,
      user_ids: params[:user_ids]
    ).call

    if result.added_user_ids.present?
      RoomNotificationsService.new(result.added_user_ids, current_user, @room).create_invite_notification
    end

    redirect_to result.redirect_path, alert: result.alert
  end

  def update
    role = params.dig(:participant, :role) || params[:role]

    if @participant.update(role: role)
      broadcast_participant_role_value!

      broadcast_conversation_options!

      RoomNotificationsService.new([], current_user, @room).notification_role_changed(@participant.user)

      redirect_to room_path(@room)
    else
      redirect_to room_path(@room), alert: @participant.errors.full_messages.to_sentence
    end
  end

  def destroy
    return redirect_to room_path(@room), alert: 'Owner cannot be removed' if @participant.owner?

    removed_user = @participant.user
    self_removal = removed_user.id == current_user.id

    if @participant.destroy
      RoomNotificationsService.new([], current_user, @room).notification_member_removed(removed_user, self_removal)
      RoomChannel.broadcast_to(removed_user, action: 'delete', room_id: @room.id)
      redirect_to room_path(@room)
    else
      redirect_to room_path(@room), alert: @participant.errors.full_messages.to_sentence
    end
  end

  private

  def set_room
    room_id = params.dig(:participant, :room_id) || params[:room_id]
    @room = Room.find(room_id)
  end

  def set_participant
    @participant = @room.participants.find_by!(user_id: params.expect(:user_id))
  end

  def participant_params
    params.expect(participant: %i[room_id role])
  end

  def ensure_room_owner!
    participant = current_room_participant

    return if participant&.owner?

    redirect_to rooms_path, alert: 'Only owner can appoint as moderator'
  end

  def ensure_owner_or_moderator!
    return if self_removal!

    participant = current_room_participant

    return if participant&.owner? || participant&.moderator?

    redirect_to rooms_path, alert: 'Only owner or moderator can exclude members'
  end

  def ensure_can_invite!
    return if params[:user_ids].blank?
    return if current_room_participant.present?

    redirect_to rooms_path, alert: 'Only conversation members can invite users'
  end

  def current_room_participant
    return @current_room_participant if defined?(@current_room_participant)

    @current_room_participant = @room.participants.find_by(user_id: current_user.id)
  end

  def broadcast_conversation_options!
    fresh_room = Room.find(@room.id)

    fresh_room.participants.includes(:user).find_each do |participant|
      Turbo::StreamsChannel.broadcast_replace_to(
        [fresh_room, participant.user],
        target: 'conversation_options_modal',
        partial: 'rooms/conversation_options',
        locals: { room: fresh_room, current_user: participant.user }
      )
    end
  end

  def broadcast_participant_role_value!
    Turbo::StreamsChannel.broadcast_replace_to(
      @room,
      target: view_context.dom_id(@participant, :role_value),
      partial: 'participants/role_value',
      locals: { participant: @participant, editable: false }
    )
  end

  def self_removal!
    @participant.user_id == current_user.id
  end

  def user_ids
    @added_user_ids = Array(params[:user_ids]).map(&:to_i).select(&:positive?).uniq
  end
end
