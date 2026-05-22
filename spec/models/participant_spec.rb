# frozen_string_literal: true

RSpec.describe Participant, type: :model do
  describe 'roles' do
    subject(:participant) { described_class.new(role: 'Moderator') }

    it 'maps moderator role values' do
      expect(participant).to be_moderator
    end
  end
end
