class MessagesController < ApplicationController
  before_action :set_conversation, only: :create

  def create
    @message = Message.new(user: current_user, conversation: @conversation, content: message_params[:content])

    if @message.save
      redirect_to conversation_path(@conversation)
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(message_params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:content, :conversation_id)
  end
end
