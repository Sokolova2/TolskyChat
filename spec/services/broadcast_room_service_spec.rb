# frozen_string_literal: true

RSpec.describe BroadcastRoomService do
  describe '#broadcast_room' do
    subject(:broadcast_room) { described_class.new(room).broadcast_room }

    let(:user) { create_user }
    let(:room) { create_room(owner: user) }

    before do
      allow(ApplicationController).to receive(:render).and_return('<div>room</div>')
      allow(RoomChannel).to receive(:broadcast_to)
    end

    it 'broadcasts an upsert payload to participants' do
      broadcast_room

      expect(RoomChannel).to have_received(:broadcast_to).with(user, hash_including(action: 'upsert'))
    end
  end
end
