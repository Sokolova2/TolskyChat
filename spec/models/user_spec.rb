# frozen_string_literal: true

RSpec.describe User, type: :model do
  describe '.from_omniauth' do
    subject(:from_omniauth) { described_class.from_omniauth(auth) }

    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: 'uid-1',
        info: { email: 'oauth@example.com' }
      )
    end

    it 'creates a confirmed user from auth data' do
      expect(from_omniauth).to be_confirmed
    end
  end

  describe '.search' do
    subject(:search) { described_class.search('ali') }

    before do
      create_user(login: 'alice')
      create_user(login: 'bob')
    end

    it 'returns users matching login' do
      expect(search.pluck(:login)).to contain_exactly('alice')
    end
  end
end
