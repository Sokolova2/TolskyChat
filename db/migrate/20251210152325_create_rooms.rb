# frozen_string_literal: true

class CreateRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms do |t|
      t.string :name
      t.boolean :is_private, default: false, null: false
      t.string :type
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
