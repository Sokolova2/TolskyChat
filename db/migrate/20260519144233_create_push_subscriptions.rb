class CreatePushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :push_subscriptions do |t|
      t.string :endpoint
      t.string :auth_key
      t.string :p256dh_key
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
