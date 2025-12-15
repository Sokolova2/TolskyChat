class Conversation < Room
  has_many :participants, foreign_key: :conversation_id, dependent: :destroy
end
