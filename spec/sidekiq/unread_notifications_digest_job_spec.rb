# frozen_string_literal: true

RSpec.describe UnreadNotificationsDigestJob do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    let(:sender) { create_user(login: 'sender') }
    let(:receiver) { create_user(login: 'receiver') }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

    before do
      allow(NotificationsChannel).to receive(:broadcast_to)
      allow(NotificationMailer).to receive(:unread_digest).and_return(mail)
      Notification.create!(sender: sender, receiver: receiver, content: 'Unread', created_at: 2.hours.ago)
    end

    it 'delivers one digest email' do
      perform

      expect(mail).to have_received(:deliver_now)
    end
  end
end
