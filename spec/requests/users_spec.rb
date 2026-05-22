# frozen_string_literal: true

RSpec.describe 'Users', type: :request do
  describe 'PATCH /users/register_subscription' do
    subject(:register_subscription) do
      patch register_subscription_users_path, params: { subscription: subscription.to_json }
    end

    let(:user) { create_user }
    let(:subscription) do
      {
        endpoint: 'https://push.example.test/endpoint',
        keys: { auth: 'auth', p256dh: 'p256dh' }
      }
    end

    before { sign_in user }

    it 'creates a push subscription' do
      expect { register_subscription }.to change(PushSubscription, :count).by(1)
    end
  end
end
