# frozen_string_literal: true

class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :room

  enum :role, {
    member: 'Member',
    owner: 'Owner',
    moderator: 'Moderator'
  }
end
