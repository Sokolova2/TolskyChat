# frozen_string_literal: true

class Room < ApplicationRecord
  validates_uniqueness_of :name, presence: true
  scope :public_rooms, -> { where(is_private: false) }
end
