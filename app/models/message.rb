# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room

  has_one_attached :featured_image
  has_one_attached :audio_file

  has_rich_text :content

  validate :audio_or_text_present

  private

  def audio_or_text_present
    if content.blank? && !audio_file.attached?
      errors.add(:base, "Message can't be empty")
    end
  end
end


