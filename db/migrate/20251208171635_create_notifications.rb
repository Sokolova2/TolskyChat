class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.string :content
      t.string :read
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
