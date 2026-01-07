# frozen_string_literal: true

class ChatroomChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])

    stream_for conversation
  end

  def unsubscribed
    stop_all_streams
  end
end
