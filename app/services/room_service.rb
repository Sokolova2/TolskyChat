# frozen_string_literal: true

class RoomService
  def initialize(params = {}, user)
    @params = params
    @user = user
  end

  def call
    conversation = Conversation.create(@params)

    if conversation.save
      conversation.participants.create(user: @user, room: conversation, role: 'Owner')
    end

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