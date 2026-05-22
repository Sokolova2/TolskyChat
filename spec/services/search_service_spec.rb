# frozen_string_literal: true

RSpec.describe SearchService do
  describe '#search_room' do
    subject(:search) { described_class.new(Room).search_room('lobby') }

    before do
      create_room(name: 'lobby')
      create_room(name: 'support')
    end

    it 'filters rooms by name' do
      expect(search.pluck(:name)).to contain_exactly('lobby')
    end
  end
end
