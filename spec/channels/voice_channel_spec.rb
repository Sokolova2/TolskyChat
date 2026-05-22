# frozen_string_literal: true

RSpec.describe VoiceChannel, type: :channel do
  describe '#signal' do
    subject(:signal) { perform :signal, 'receiver_id' => receiver.id, 'type' => 'offer' }

    let(:current_user) { create_user }
    let(:receiver) { create_user }

    before do
      stub_connection current_user: current_user
      subscribe
      allow(described_class).to receive(:broadcast_to)
    end

    it 'broadcasts signal data to the receiver' do
      signal

      expect(described_class).to have_received(:broadcast_to).with(receiver, hash_including('type' => 'offer'))
    end
  end
end
