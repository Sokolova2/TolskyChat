# frozen_string_literal: true

RSpec.describe PushSubscription, type: :model do
  describe 'validations' do
    subject(:subscription) do
      described_class.new(user: create_user, endpoint: endpoint, auth_key: 'auth', p256dh_key: 'key')
    end

    let(:endpoint) { 'https://push.example.test/1' }

    before { described_class.create!(user: create_user, endpoint: endpoint, auth_key: 'auth2', p256dh_key: 'key2') }

    it 'requires a unique endpoint' do
      expect(subscription).not_to be_valid
    end
  end
end
