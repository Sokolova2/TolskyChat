# frozen_string_literal: true

class ParticipantsController < ApplicationController
  before_action :set_room, only: :create

  def create
    result = ParticipantsCreateService.new(
      room: @room,
      current_user: current_user,
      user_ids: params[:user_ids]
    ).call

    redirect_to result.redirect_path, alert: result.alert
  end

  private

  def set_room
    @room = Room.find(participant_params[:room_id])
  end

  def participant_params
    params.require(:participant).permit(:room_id)
  end
end
