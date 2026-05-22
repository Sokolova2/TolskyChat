# frozen_string_literal: true

RSpec.describe 'Notifications', type: :request do
  describe 'DELETE /notifications/clear_all' do
    subject(:clear_all_notifications) { delete clear_all_notifications_path }

    let(:current_user) { create_user }
    let(:sender) { create_user }
    let(:other_user) { create_user }

    before do
      sign_in current_user, scope: :user
      allow(NotificationsChannel).to receive(:broadcast_to)

      Notification.create!(sender: sender, receiver: current_user, content: 'for current user')
      Notification.create!(sender: sender, receiver: current_user, content: 'for current user too')
      Notification.create!(sender: sender, receiver: other_user, content: 'for another user')
    end

    it 'deletes only current user notifications' do
      expect { clear_all_notifications }.to change { current_user.receiver_notifications.count }.from(2).to(0)
      expect(other_user.receiver_notifications.count).to eq(1)
      expect(response).to redirect_to(notifications_path)
    end
  end
end
