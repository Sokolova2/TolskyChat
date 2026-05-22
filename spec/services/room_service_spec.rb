# frozen_string_literal: true

RSpec.describe RoomService do
  describe '#call' do
    subject(:conversation) { described_class.new(user, name: 'Spec Room').call }

    let(:user) { create_user }

    it 'creates an owner participant' do
      expect(conversation.participants.first).to be_owner
    end
  end

  describe '#call_chat' do
    subject(:chat) { described_class.new(user).call_chat(second_user) }

    let(:user) { create_user(login: 'first') }
    let(:second_user) { create_user(login: 'second') }

    it 'creates a private personal chat' do
      expect(chat.is_private?).to be(true)
    end
  end
end
