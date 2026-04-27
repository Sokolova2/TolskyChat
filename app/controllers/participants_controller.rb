# frozen_string_literal: true

class ParticipantsController < ApplicationController
  before_action :set_conversation, only: :create

  def create
    params[:user_ids]&.each do |id|
      @conversation.participants.find_or_create_by(user_id: id)
    end

    redirect_to room_path(@conversation)
  end

  private

  def set_conversation
    @conversation = Room.find(participant_params[:room_id])
  end

  def participant_params
    params.require(:participant).permit(:user_id, :room_id)
  end
end
