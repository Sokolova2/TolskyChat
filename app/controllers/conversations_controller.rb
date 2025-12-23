class ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[show destroy]
  def index
    @conversations = Conversation.all
  end

  def show; end

  def new
    @conversation_new = Conversation.new
    @conversation_new.participants.build
  end

  def create
    @conversation_new = RoomService.new(conversation_params, current_user).call

    if @conversation_new.save
      respond_to do |format|
        format.turbo_stream
        format.html {redirect_to conversations_path}
      end
    else
      redirect_to new_conversation_path, alert: @conversation_new.errors.full_messages
    end
  end

  def destroy
    @conversation.destroy

    redirect_to rooms_path
  end

  private

  def conversation_params
    params.require(:conversation).permit(
      :name, :is_private,
      :deleted_at,
      participants_attributes: [:user_id, :role])
  end

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
end
