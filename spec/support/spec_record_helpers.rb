# frozen_string_literal: true

module SpecRecordHelpers
  def create_user(login: nil, email: nil)
    value = SecureRandom.hex(4)

    User.create!(
      email: email || "user-#{value}@example.com",
      login: login || "user_#{value}",
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end

  def create_room(name: nil, type: 'Conversation', is_private: false, owner: nil)
    user = owner || create_user
    room = type.constantize.create!(
      name: name || "room-#{SecureRandom.hex(4)}",
      is_private: is_private
    )
    room.participants.create!(user: user, role: 'Owner')
    room
  end

  def create_message(room:, user:, content: 'hello', read: false, created_at: Time.current)
    room.messages.create!(user: user, content: content, read: read, created_at: created_at)
  end
end
