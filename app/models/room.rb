# frozen_string_literal: true

class Room < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :messages, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  scope :public_rooms, -> { where(is_private: false) }

  def other_user(current_user)
    participants
      .includes(:user)
      .map(&:user)
      .find { |u| u.id != current_user.id }
  end

  def display_name(current_user)
    return name unless is_private? && is_a?(PersonalChat)

    other_user(current_user)&.login || name
  end

  def display_avatar(current_user)
    return nil unless is_private? && is_a?(PersonalChat)

    other_user(current_user)&.avatar
  end

  class << self
    def search(search)
      SearchService.new(self).search_room(search)
    end
  end
end
