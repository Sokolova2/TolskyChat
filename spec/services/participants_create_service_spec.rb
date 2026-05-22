# frozen_string_literal: true

RSpec.describe ParticipantsCreateService do
  describe '#call' do
    subject(:result) { described_class.new(room: room, current_user: current_user, user_ids: user_ids).call }

    let(:current_user) { create_user(login: 'owner') }
    let(:room) { create_room(owner: current_user) }

    before do
      service = instance_double(BroadcastRoomService, broadcast_room: true)

      allow(BroadcastRoomService).to receive(:new).and_return(service)
    end

    context 'when adding users as a room member' do
      let(:added_user) { create_user(login: 'added') }
      let(:user_ids) { [added_user.id.to_s] }

      it 'returns added user ids' do
        expect(result.added_user_ids).to contain_exactly(added_user.id)
      end
    end

    context 'when the target user blocked the current user' do
      let(:blocked_user) { create_user(login: 'blocked') }
      let(:user_ids) { [blocked_user.id] }

      before do
        Contact.create!(sender: blocked_user, receiver: current_user, blocked: true)
      end

      it 'returns a failed result' do
        expect(result.ok).to be(false)
      end
    end

    context 'when self-joining a private room' do
      let(:room) { create_room(is_private: true) }
      let(:user_ids) { [] }

      it 'rejects the join' do
        expect(result.alert).to eq('Only public chats can be joined')
      end
    end
  end
end
