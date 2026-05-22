# frozen_string_literal: true

RSpec.describe 'TURN credentials', type: :request do
  describe 'GET /turn_credentials' do
    subject(:show_credentials) { get turn_credentials_path }

    let(:user) { create_user }

    before do
      sign_in user
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('TWILIO_ACCOUNT_SID').and_return(nil)
      allow(ENV).to receive(:[]).with('TWILIO_AUTH_TOKEN').and_return(nil)
    end

    it 'returns an unprocessable response when Twilio is not configured' do
      show_credentials

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
