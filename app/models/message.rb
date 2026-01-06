class Message < ApplicationRecord
  belongs_to :user
  belongs_to :conversation, class_name: 'Room', foreign_key: :conversation_id

  validates :content, presence: true

  has_rich_text :content
  has_one_attached :featured_image
end


