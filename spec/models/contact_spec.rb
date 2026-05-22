# frozen_string_literal: true

RSpec.describe Contact, type: :model do
  describe '#unique_contact' do
    subject(:contact) { described_class.new(sender: receiver, receiver: sender) }

    let(:sender) { create_user(login: 'sender') }
    let(:receiver) { create_user(login: 'receiver') }

    before do
      described_class.create!(sender: sender, receiver: receiver)
      contact.valid?
    end

    it 'rejects inverse duplicate contacts' do
      expect(contact.errors[:base]).to include('Contact already exists')
    end
  end

  describe '.user_contacts' do
    subject(:contacts) { described_class.user_contacts(user.id) }

    let(:user) { create_user(login: 'owner') }
    let(:friend) { create_user(login: 'friend') }

    before do
      described_class.create!(sender: user, receiver: friend, approved: true)
    end

    it 'returns approved contacts for the user' do
      expect(contacts.map(&:contact_id)).to contain_exactly(described_class.first.id)
    end
  end
end
