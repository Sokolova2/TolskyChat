# frozen_string_literal: true

RSpec.describe 'Participants', type: :request do
  describe 'POST /participants' do
    subject(:create_participant) { post participants_path, params: { room_id: room.id, user_ids: user_ids } }

    let(:owner) { create_user }
    let(:room) { create_room(owner: owner) }
    let(:invitee) { create_user }
    let(:user_ids) { [invitee.id] }

    context 'when user_ids are blank' do
      let(:user_ids) { [] }

      before do
        room
        sign_in owner, scope: :user
      end

      it 'redirects back to room without changes' do
        expect { create_participant }.not_to change(Participant, :count)
        expect(response).to redirect_to(room_path(room))
      end
    end

    context 'when current user is not a room participant' do
      let(:outsider) { create_user }

      before do
        room
        sign_in outsider, scope: :user
      end

      it 'forbids invite action via pundit' do
        expect { create_participant }.not_to change(Participant, :count)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when current user is room participant' do
      before do
        room
        sign_in owner, scope: :user
      end

      it 'adds invited user as participant' do
        expect { create_participant }.to change(Participant, :count).by(1)
        expect(response).to redirect_to(room_path(room))
      end
    end
  end

  describe 'PATCH /participants/:id/toggle_mute' do
    subject(:toggle_mute) { patch toggle_mute_participant_path(participant), params: { room_id: room.id } }

    let(:user) { create_user }
    let(:room) { create_room(owner: user) }
    let(:participant) { room.participants.find_by!(user: user) }

    before { sign_in user, scope: :user }

    it 'toggles muted state' do
      expect { toggle_mute }.to change { participant.reload.muted? }.from(false).to(true)
    end
  end

  describe 'PATCH /participants/:id/toggle_mute as outsider' do
    subject(:toggle_mute) { patch toggle_mute_participant_path(participant), params: { room_id: room.id } }

    let(:owner) { create_user }
    let(:outsider) { create_user }
    let(:room) { create_room(owner: owner) }
    let(:participant) { room.participants.find_by!(user: owner) }

    before { sign_in outsider, scope: :user }

    it 'is forbidden by pundit' do
      toggle_mute

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('You are not authorized to perform this action.')
    end
  end
end
