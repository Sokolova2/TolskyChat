class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.string :name
      t.boolean :public, default: true
      t.string :type

      t.datetime :deleted_at

      t.timestamps
    end
  end
end
