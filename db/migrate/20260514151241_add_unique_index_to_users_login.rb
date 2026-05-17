# frozen_string_literal: true

class AddUniqueIndexToUsersLogin < ActiveRecord::Migration[8.1]
  def change
    add_index :users, :login, unique: true
  end
end
