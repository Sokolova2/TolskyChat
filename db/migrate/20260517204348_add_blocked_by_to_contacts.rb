class AddBlockedByToContacts < ActiveRecord::Migration[8.1]
  def change
    add_column :contacts, :blocked_by_id, :bigint
  end
end
