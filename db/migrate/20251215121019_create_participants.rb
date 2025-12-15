class CreateParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :participants do |t|
      t.belongs_to :user, null: false, foreign_key: true

      t.bigint :conversation_id, null: false
      t.foreign_key :rooms, column: :conversation_id

      t.string :role, default: 'Member', null: false

      t.timestamps
    end
  end
end
