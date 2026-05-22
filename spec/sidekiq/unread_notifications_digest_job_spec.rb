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
    end

    it 'delivers digest only for notifications in 60..75 minutes window' do
      Notification.create!(sender: sender, receiver: receiver, content: 'In window', created_at: 61.minutes.ago)
      Notification.create!(sender: sender, receiver: receiver, content: 'Too old', created_at: 90.minutes.ago)
      Notification.create!(sender: sender, receiver: receiver, content: 'Too new', created_at: 50.minutes.ago)

      perform

      expect(mail).to have_received(:deliver_now)
      expect(NotificationMailer).to have_received(:unread_digest).with(
        receiver,
        contain_exactly(have_attributes(content: 'In window'))
      )
    end
  end
end
