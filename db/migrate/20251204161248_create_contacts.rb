class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.belongs_to :sender, null: false, foreign_key: {  to_table: :users }
      t.belongs_to :receiver, null: false, foreign_key: {  to_table: :users }
      t.boolean :approved, default: false
      t.boolean :blocked, default: false

      t.timestamps
    end
  end
end
