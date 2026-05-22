# frozen_string_literal: true

RSpec.describe RoomNotificationsService do
  describe '#create_invite_notification' do
    subject(:create_invite_notification) do
      described_class.new([added_user.id], sender, room).create_invite_notification
    end

    let(:sender) { create_user(login: 'owner') }
    let(:observer) { create_user(login: 'observer') }
    let(:added_user) { create_user(login: 'new_member') }
    let(:room) { create_room(name: 'Team', owner: sender) }

    before do
      allow(NotificationsChannel).to receive(:broadcast_to)
      room.participants.create!(user: observer, role: 'Member')
    end

    it 'creates notifications for invited user and room members' do
      expect { create_invite_notification }.to change(Notification, :count).by(2)
    end
  end
end
