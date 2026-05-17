# frozen_string_literal: true

class RoomService
  def initialize(user, params = {})
    @user = user
    @params = params
  end

  def call
    conversation = Conversation.create(@params)

    conversation.participants.create(user: @user, room: conversation, role: 'Owner') if conversation.save

    conversation
  end

  def call_chat(second_user)
    chat = PersonalChat.create(name: second_user.login, is_private: true)

    if chat.save
      chat.participants.create(user: @user, room: chat, role: 'Member')
      chat.participants.create(user: second_user, room: chat, role: 'Member')
    end

    chat
  end
end
