class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.bigint :conversation_id, null: false
      t.foreign_key :rooms, column: :conversation_id
      t.string :content
      t.boolean :read, default: false, null: false

      t.timestamps
    end
  end
end
