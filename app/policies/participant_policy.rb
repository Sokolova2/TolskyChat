#frozen_string_literal: true

class ParticipantPolicy < ApplicationPolicy
  def invite?
    participant.present?
  end

  def update?
    actor&.owner?
  end

  def destroy?
    return true if self_removal?

    actor&.owner? || actor&.moderator?
  end

  private

  def room
    record.room
  end

  def actor
    @actor ||= room.participants.find_by(user_id: user.id)
  end

  def self_removal?
    record.user_id == user.id
  end
end