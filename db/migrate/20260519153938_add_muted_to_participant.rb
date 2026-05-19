class AddMutedToParticipant < ActiveRecord::Migration[8.1]
  def change
    add_column :participants, :muted, :boolean, null: false, default: false
  end
end
