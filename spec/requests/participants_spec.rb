# frozen_string_literal: true

RSpec.describe 'Participants', type: :request do
  describe 'PATCH /participants/:id/toggle_mute' do
    subject(:toggle_mute) { patch toggle_mute_participant_path(participant), params: { room_id: room.id } }

    let(:user) { create_user }
    let(:room) { create_room(owner: user) }
    let(:participant) { room.participants.find_by!(user: user) }

    before { sign_in user }

    it 'toggles muted state' do
      expect { toggle_mute }.to change { participant.reload.muted? }.from(false).to(true)
    end
  end
end
