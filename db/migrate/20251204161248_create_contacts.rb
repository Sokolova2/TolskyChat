class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.boolean :approved, default: false
      t.boolean :blocked, default: false

      t.timestamps
    end
  end
end
