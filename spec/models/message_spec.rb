# frozen_string_literal: true

RSpec.describe Message, type: :model do
  describe 'validations' do
    subject(:message) { described_class.new(room: room, user: user, content: '') }

    let(:user) { create_user }
    let(:room) { create_room(owner: user) }

    before { message.valid? }

    it 'requires text or audio content' do
      expect(message.errors[:base]).to include("Message can't be empty")
    end
  end
end
