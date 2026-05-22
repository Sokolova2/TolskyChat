# frozen_string_literal: true

RSpec.describe 'Rooms', type: :request do
  describe 'GET /rooms/:id' do
    subject(:show_room) { get room_path(room) }

    let(:current_user) { create_user }
    let(:room) { create_room(is_private: true) }

    before { sign_in current_user }

    it 'redirects non-participants away from private rooms' do
      show_room

      expect(response).to redirect_to(rooms_path)
    end
  end

  describe 'GET /rooms/public_search' do
    subject(:public_search) { get public_search_rooms_path, params: { search: 'open' } }

    let(:current_user) { create_user }

    before do
      sign_in current_user
      create_room(name: 'open-room')
    end

    it 'responds successfully for signed-in users' do
      public_search

      expect(response).to have_http_status(:ok)
    end
  end
end
