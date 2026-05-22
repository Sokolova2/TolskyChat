class RoomPolicy < ApplicationPolicy
  def show?
    return true unless record.is_private?

    participant.present?
  end

  def update?
    return false if participant.blank?
    return true if record.is_a?(PersonalChat)

    participant.owner?
  end

  def destroy?
    return false if participant.blank?
    return true if record.is_a?(PersonalChat)

    participant.owner?
  end

  def archive?
    Room.joins(:participants).exists?(
      participants: { user_id: user.id, role: :owner }
    )
  end

  def public_search?
    true
  end

  def invite?
    participant.present?
  end

  def toggle_mute?
    participant.present?
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