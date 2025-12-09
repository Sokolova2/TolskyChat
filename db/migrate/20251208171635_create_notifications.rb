# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.string :content
      t.string :read, default: false
      t.belongs_to :sender, null: false, foreign_key: { to_table: :users }
      t.belongs_to :receiver, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
