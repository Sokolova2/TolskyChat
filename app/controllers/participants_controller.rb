class ParticipantsController < ApplicationController
  before_action :set_conversation, only: :create

  def create
    params[:user_ids]&.each do |id|
      @conversation.participants.find_or_create_by(user_id: id)
    end

    redirect_to rooms_path
  end

  private

  def set_conversation
    @conversation = Conversation.find(participant_params[:conversation_id])
  end

  def participant_params
    params.require(:participant).permit(:user_id, :conversation_id)
  end
end
