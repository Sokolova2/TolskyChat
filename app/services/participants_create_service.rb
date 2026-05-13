# frozen_string_literal: true

class ParticipantsCreateService
  Result = Struct.new(:ok, :redirect_path, :alert, keyword_init: true)

  def initialize(room:, current_user:, user_ids:)
    @room = room
    @current_user = current_user
    @user_ids = normalize_user_ids(user_ids)
  end

  def call
    return bulk_add if @user_ids.present?
    self_join
  end

  private

  def bulk_add
    return forbidden_result unless can_manage_participants?

    @user_ids.each do |id|
      @room.participants.find_or_create_by(user_id: id)
    end

    BroadcastRoomService.new(@room).broadcast_room

    success_result(room_path(@room))
  end

  def self_join
    return public_only_result if @room.is_private? || @room.deleted_at.present?

    @room.participants.find_or_create_by(user_id: @current_user.id)
    success_result(room_path(@room))
  end

  def can_manage_participants?
    @room.participants.exists?(user_id: @current_user.id) && @room.deleted_at.nil?
  end

  def normalize_user_ids(raw_ids)
    return [] unless raw_ids.present?

    raw_ids.map(&:to_i).select(&:positive?).uniq
  end

  def success_result(path)
    Result.new(ok: true, redirect_path: path, alert: nil)
  end

  def forbidden_result
    Result.new(ok: false, redirect_path: rooms_path, alert: 'Forbidden')
  end

  def public_only_result
    Result.new(ok: false, redirect_path: rooms_path, alert: 'Only public chats can be joined')
  end

  def room_path(room)
    Rails.application.routes.url_helpers.room_path(room)
  end

  def rooms_path
    Rails.application.routes.url_helpers.rooms_path
  end
end
