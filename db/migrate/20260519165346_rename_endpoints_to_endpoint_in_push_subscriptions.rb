class RenameEndpointsToEndpointInPushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    return if column_exists?(:push_subscriptions, :endpoint)
    return unless column_exists?(:push_subscriptions, :endpoints)

    rename_column :push_subscriptions, :endpoints, :endpoint
  end
end
