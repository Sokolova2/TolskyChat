# frozen_string_literal: true

RSpec.describe ArchiveCleanupJob do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    before do
      Conversation.create!(name: 'old', deleted_at: 4.months.ago)
      Conversation.create!(name: 'recent', deleted_at: 1.week.ago)
    end

    it 'removes rooms archived for more than three months' do
      expect { perform }.to change(Room, :count).by(-1)
    end
  end
end
