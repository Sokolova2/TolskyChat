class RemoveContentFromMessage < ActiveRecord::Migration[8.1]
  def change
    remove_column :messages, :content, :string if column_exists?(:messages, :content)
  end
end