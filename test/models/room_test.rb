# frozen_string_literal: true

require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  test 'conversation keeps own name when private' do
    owner = User.create!(
      email: 'owner@example.com',
      login: 'owner_login',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
    member = User.create!(
      email: 'member@example.com',
      login: 'member_login',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
    room = Conversation.create!(name: 'Team Secret', is_private: true)
    room.participants.create!(user: owner, role: 'Owner')
    room.participants.create!(user: member, role: 'Member')

    assert_equal 'Team Secret', room.display_name(owner)
  end

  test 'personal chat uses other user login when private' do
    owner = User.create!(
      email: 'chat_owner@example.com',
      login: 'chat_owner',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
    member = User.create!(
      email: 'chat_member@example.com',
      login: 'chat_member',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
    chat = PersonalChat.create!(name: 'placeholder', is_private: true)
    chat.participants.create!(user: owner, role: 'Owner')
    chat.participants.create!(user: member, role: 'Owner')

    assert_equal 'chat_member', chat.display_name(owner)
  end
end
