# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_conversation, only: :create

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

  private

  def set_conversation
    @conversation = Conversation.find(message_params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:content, :conversation_id, :featured_image)
  end
end
