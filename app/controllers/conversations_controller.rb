class ConversationsController < ApplicationController
  def index
    @conversations = Conversation.all
  end

  def show
    @conversation = Conversation.find(params[:id])
  end

  def new
    @conversation_new = Conversation.new
  end

  def create
    @conversation_new = RoomService.new(conversation_params, current_user).call

    if @conversation_new.save
      redirect_to conversation_path(@conversation_new)
    else
      redirect_to new_conversation_path, alert: @conversation_new.errors.full_messages
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:name, :is_private, :deleted_at)
  end
end
