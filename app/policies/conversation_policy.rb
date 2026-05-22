# frozen_string_literal: true

class ConversationPolicy < RoomPolicy
  def index?
    true
  end

  def new?
    true
  end

  def show?
    return true unless record.is_private?
    participant.present?
  end

  def destroy?
    participant&.owner?
  end

  def create?
    true
  end

  def update?
    participant&.owner? || participant&.moderator?
  end

  class Scope < Scope
    def resolve
      scope
        .joins(:participants)
        .where(participants: { user_id: user.id })
        .where(deleted_at: nil)
        .distinct
    end
  end

  private

  def participant
    @participant ||= record.participants.find_by(user_id: user.id)
  end
end