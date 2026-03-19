# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :user
  belongs_to :conversation, class_name: 'Room', foreign_key: :conversation_id

  has_one_attached :featured_image
  has_rich_text :content

  validates :content, presence: true
end


