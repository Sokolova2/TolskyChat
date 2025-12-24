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
end
