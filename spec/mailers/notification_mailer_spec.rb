# frozen_string_literal: true

RSpec.describe NotificationMailer, type: :mailer do
  describe '#unread_digest' do
    subject(:mail) { described_class.unread_digest(user, [notification]) }

    let(:sender) { create_user(login: 'sender') }
    let(:user) { create_user(email: 'recipient@example.com') }
    let(:notification) { Notification.new(sender: sender, receiver: user, content: 'Unread') }

    it 'sends to the user email' do
      expect(mail.to).to contain_exactly('recipient@example.com')
    end
  end
end
