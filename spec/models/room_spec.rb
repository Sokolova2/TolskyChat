# frozen_string_literal: true

RSpec.describe Room, type: :model do
  describe '#display_name' do
    subject(:display_name) { room.display_name(current_user) }

    let(:current_user) { create_user(login: 'owner_login') }

    context 'with a private conversation' do
      let(:room) { create_room(name: 'Team Secret', is_private: true, owner: current_user) }

      it 'keeps the room name' do
        expect(display_name).to eq('Team Secret')
      end
    end

    context 'with a private personal chat' do
      let(:other_user) { create_user(login: 'chat_member') }
      let(:room) do
        create_room(name: 'placeholder', type: 'PersonalChat', is_private: true, owner: current_user).tap do |chat|
          chat.participants.create!(user: other_user, role: 'Owner')
        end
      end

      it 'uses the other user login' do
        expect(display_name).to eq('chat_member')
      end
    end
  end

  describe '.search' do
    subject(:search) { described_class.search('general') }

    before do
      create_room(name: 'general')
      create_room(name: 'random')
    end

    it 'returns rooms matching the name' do
      expect(search.pluck(:name)).to contain_exactly('general')
    end
  end
end
