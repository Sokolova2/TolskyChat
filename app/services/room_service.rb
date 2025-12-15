# frozen_string_literal: true

class RoomService
  def initialize(params, user)
    @params = params
    @user = user
  end

  def call
    conversation = Conversation.create(@params)

    Participant.create(user: @user, conversation: conversation, role: 'Owner')

    conversation
  end
end