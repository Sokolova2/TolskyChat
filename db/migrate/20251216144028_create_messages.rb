# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :room, null: false, foreign_key: true
      t.boolean :read, default: false, null: false

      t.timestamps
    end
  end
end
