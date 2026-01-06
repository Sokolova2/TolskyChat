class RemoveContentFromMessage < ActiveRecord::Migration[8.1]
  def change
    remove_column :messages, :content, :string
  end
end
