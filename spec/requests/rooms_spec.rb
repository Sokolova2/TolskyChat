# frozen_string_literal: true

RSpec.describe 'Rooms', type: :request do
  describe 'GET /rooms/:id' do
    subject(:show_room) { get room_path(room) }

    let(:current_user) { create_user }
    let(:room_owner) { create_user }
    let(:room) { create_room(owner: room_owner, is_private: true) }

    before { sign_in current_user, scope: :user }

    it 'redirects non-participants away from private rooms' do
      show_room

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('You are not authorized to perform this action.')
    end

    context 'when user is participant of private room' do
      before do
        room.participants.create!(user: current_user, role: 'Member')
      end

      it 'allows access' do
        show_room

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /archive' do
    subject(:archive_rooms) { get archive_path }

    let(:current_user) { create_user }
    let(:owner) { create_user }
    let(:room) { create_room(owner: owner) }

    before do
      sign_in current_user, scope: :user
      room.update!(deleted_at: Time.current)
    end

    it 'forbids non-owners' do
      archive_rooms

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Only owner can archive room')
    end

    context 'when current user owns at least one room' do
      before do
        room.participants.find_by!(user_id: owner.id).update!(user: current_user)
      end

      it 'allows archive page' do
        archive_rooms

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /rooms/public_search' do
    subject(:public_search) { get public_search_rooms_path, params: { search: 'open' } }

    let(:current_user) { create_user }

    before do
      sign_in current_user, scope: :user
      create_room(name: 'open-room')
    end

    it 'responds successfully for signed-in users' do
      public_search

      expect(response).to have_http_status(:ok)
    end
  end
end
