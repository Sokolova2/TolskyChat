class Conversation < Room
  has_many :participants, foreign_key: :conversation_id, dependent: :destroy
  has_many :messages, foreign_key: :conversation_id, dependent: :destroy

  accepts_nested_attributes_for :participants

  validates
end
