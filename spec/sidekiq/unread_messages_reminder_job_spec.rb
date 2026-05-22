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
    end

    it 'creates reminder only for messages in 30..40 minutes window' do
      create_message(room: room, user: sender, read: false, created_at: 31.minutes.ago)
      create_message(room: room, user: sender, read: false, created_at: 45.minutes.ago)
      create_message(room: room, user: sender, read: false, created_at: 20.minutes.ago)

      expect { perform }.to change(Notification, :count).by(1)
    end
  end
end
