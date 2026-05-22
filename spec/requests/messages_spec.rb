# frozen_string_literal: true

RSpec.describe 'Messages', type: :request do
  describe 'POST /rooms/:room_id/messages' do
    subject(:create_message) { post room_messages_path(room), params: { message: { content: 'Hello' } } }

    let(:user) { create_user }
    let(:room) { create_room(owner: user) }

    before do
      sign_in user, scope: :user
      allow(ChatroomChannel).to receive(:broadcast_to)
      allow(NotificationsChannel).to receive(:broadcast_to)
    end

    it 'creates a message' do
      expect { create_message }.to change(Message, :count).by(1)
    end
  end

  describe 'DELETE /rooms/:room_id/messages/:id' do
    subject(:destroy_message) { delete room_message_path(room, message) }

    let(:owner) { create_user }
    let(:other_user) { create_user }
    let(:room) { create_room(owner: owner) }
    let(:message) { create_message(room: room, user: owner) }

    before { sign_in other_user, scope: :user }

    it 'forbids deleting another user message' do
      destroy_message

      expect(response).to have_http_status(:forbidden)
    end
  end
end
