# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_conversation, only: :create
  before_action :set_conversation_from_params, only: :destroy

  def create
    message = Message.new(message_params)
    message.user = current_user

    return unless message.save

    ChatroomChannel.broadcast_to(
      @conversation,
      html: render_to_string(
        partial: 'messages/message',
        locals: { message: message }
      )
    )
    head :ok
  end

  def destroy
    message = @conversation.messages.find(params[:id])
    return head :forbidden unless message.user == current_user

    message.destroy

    ChatroomChannel.broadcast_to(
      @conversation,
      action: 'delete',
      message_id: message.id
    )

    head :ok
  end

  private

  def set_conversation
    @conversation = Conversation.find(message_params[:conversation_id])
  end

  def set_conversation_from_params
    @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:content, :conversation_id, :featured_image)
  end
end
