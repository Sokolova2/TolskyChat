# frozen_string_literal: true

class Conversation < Room
  has_many :participants, foreign_key: :room_id, dependent: :destroy
  has_many :messages, foreign_key: :room_id, dependent: :destroy
end