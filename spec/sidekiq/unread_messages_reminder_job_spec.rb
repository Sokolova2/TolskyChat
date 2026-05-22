# frozen_string_literal: true

RSpec.describe UnreadMessagesReminderJob do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    let(:sender) { create_user(login: 'sender') }
    let(:receiver) { create_user(login: 'receiver') }
    let(:room) { create_room(name: 'alerts', owner: sender) }

    before do
      allow(NotificationsChannel).to receive(:broadcast_to)
      room.participants.create!(user: receiver, role: 'Member')
      create_message(room: room, user: sender, read: false, created_at: 31.minutes.ago)
    end

    it 'creates reminder notifications for recipients' do
      expect { perform }.to change(Notification, :count).by(1)
    end
  end
end
