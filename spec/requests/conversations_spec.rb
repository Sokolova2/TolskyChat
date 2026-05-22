# frozen_string_literal: true

RSpec.describe 'Conversations', type: :request do
  describe 'PATCH /conversations/:id' do
    subject(:update_conversation) { patch conversation_path(conversation), params: { conversation: { name: 'renamed' } } }

    let(:owner) { create_user }
    let(:conversation) { create_room(type: 'Conversation', owner: owner) }

    before do
      allow_any_instance_of(BroadcastRoomService).to receive(:broadcast_room)
    end

    context 'when current user is not a participant' do
      let(:outsider) { create_user }

      before { sign_in outsider, scope: :user }

      it 'forbids update' do
        update_conversation

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when current user is moderator' do
      let(:moderator) { create_user }

      before do
        sign_in moderator, scope: :user
        conversation.participants.create!(user: moderator, role: 'Moderator')
      end

      it 'allows update' do
        update_conversation

        expect(response).to redirect_to(room_path(conversation))
        expect(conversation.reload.name).to eq('renamed')
      end
    end
  end
end
