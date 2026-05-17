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
    return blocked_chat if blocked_by?(second_user)

    chat = PersonalChat.create(name: second_user.login, is_private: true)

    if chat.save
      chat.participants.create(user: @user, room: chat, role: 'Owner')
      chat.participants.create(user: second_user, room: chat, role: 'Owner')
    end

    chat
  end

  def blocked_by?(other_user)
    Contact.exists?(sender_id: other_user.id, receiver_id: @user.id, blocked: true)
  end

  def blocked_chat
    chat = PersonalChat.new
    chat.errors.add(:base, 'You have blocked this user')
    chat
  end
end
