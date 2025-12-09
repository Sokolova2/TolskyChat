class AddContactIdToNotification < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :contact_id, :integer
    add_foreign_key :notifications, :contacts, column: :contact_id
  end
end
