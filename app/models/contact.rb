# frozen_string_literal: true

class Contact < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  has_many :notifications, dependent: :destroy

  validate :unique_contact, on: :create

  def unique_contact
    if Contact.where(
      '(sender_id = :sender AND receiver_id = :receiver)
       OR
       (sender_id = :receiver AND receiver_id = :sender)',
      sender: sender_id,
      receiver: receiver_id
    ).exists?
      errors.add(:base, 'Contact already exists')
    end
  end

  scope :between, -> (sender, receiver) do
    where(
      "(sender_id = :sender AND receiver_id = :receiver) OR
        (sender_id = :receiver AND receiver_id = :sender)",
      sender: sender, receiver: receiver
    )
  end

  scope :user_contacts, -> (user) {
    select('contacts.*, contacts.id as contact_id')
      .where(approved: true)
      .where('sender_id = :id OR receiver_id = :id', id: user)
      .joins('JOIN users AS senders_users ON senders_users.id = contacts.sender_id')
      .joins('JOIN users AS receivers_users ON receivers_users.id = contacts.receiver_id')
      .where(
        '(contacts.sender_id = :id AND receivers_users.deleted_at IS NULL) OR
         (contacts.receiver_id = :id AND senders_users.deleted_at IS NULL)',
        id: user
      )
  }
end
