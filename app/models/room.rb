# frozen_string_literal: true

class Room < ApplicationRecord
  has_many :participants, foreign_key: :room_id, dependent: :destroy
  has_many :messages, foreign_key: :room_id, dependent: :destroy

  validates_uniqueness_of :name, presence: true, uniqueness: true
  scope :public_rooms, -> { where(is_private: false) }

  def other_user(current_user)
    participants
      .includes(:user)
      .map(&:user)
      .find { |u| u.id != current_user.id }
  end

  def display_name(current_user)
    return name unless is_private?

    other_user(current_user)&.login
  end

  def display_avatar(current_user)
    return nil unless is_private?

    other_user(current_user)&.avatar
  end
end
