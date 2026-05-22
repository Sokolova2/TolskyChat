# frozen_string_literal: true

RSpec.describe NotificationServices do
  describe '#call' do
    subject(:call) do
      described_class.new(
        notification: notification,
        sender_id: receiver.id,
        receiver_id: sender.id,
        contact_id: contact.id,
        actor_login: receiver.login
      ).call
    end

    let(:sender) { create_user(login: 'sender') }
    let(:receiver) { create_user(login: 'receiver') }
    let(:contact) { Contact.create!(sender: sender, receiver: receiver) }
    let(:notification) do
      Notification.create!(sender: sender, receiver: receiver, contact: contact, content: 'Request')
    end

    before { allow(NotificationsChannel).to receive(:broadcast_to) }

    it 'destroys the original notification' do
      expect { call }.to change { Notification.exists?(notification.id) }.from(true).to(false)
    end
  end
end
