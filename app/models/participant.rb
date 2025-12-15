class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :conversation, class_name: 'Room', foreign_key: :conversation_id
end
