# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      t.string :first_name
      t.string :last_name
      t.string :login
      t.string :phone_number
      t.date :birth_date
      t.string :avatar
      t.string :description
      t.string :uid
      t.string :provider

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      t.datetime :remember_created_at

      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
  end
end
