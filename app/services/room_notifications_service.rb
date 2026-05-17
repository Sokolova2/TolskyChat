class RoomNotificationsService
  def initialize(added_user_ids, sender, room)
    @added_user_ids = added_user_ids
    @sender = sender
    @room = room
  end

  def create_invite_notification
    added_users = User.where(id: @added_user_ids).index_by(&:id)

    @added_user_ids.each do |added_user_id|
      added_user = added_users[added_user_id]
      next unless added_user

      notification_invited_you(added_user_id)
      notification_invited(added_user)
    end
  end

  def notification_invited_you(added_user_id)
    Notification.create(
      sender_id: @sender.id,
      receiver_id: added_user_id,
      contact_id: nil,
      content: "#{@sender.login} added you to the conversation #{@room.name}"
    )
  end

  def notification_invited(added_user)
    recipient_ids = Room.find(@room.id).participants.pluck(:user_id) - [@sender.id, added_user.id]

    recipient_ids.each do |receiver_id|
      Notification.create(
        sender_id: @sender.id,
        receiver_id: receiver_id,
        contact_id: nil,
        content: "#{@sender.login} added #{added_user.login} to the conversation #{@room.name}"
      )
    end
  end


  def notification_role_changed(target_user)
    role_changed_you!(target_user)
    role_changed!(target_user)
  end

  def role_changed_you!(target_user)
    Notification.create(
      sender_id: @sender.id,
      receiver_id: target_user.id,
      contact_id: nil,
      content: "#{@sender.login} appointed you as moderator in #{@room.name}"
    )
  end

  def role_changed!(target_user)
    recipient_ids = Room.find(@room.id).participants.pluck(:user_id) - [@sender.id, target_user.id]

    recipient_ids.each do |receiver_id|
      Notification.create(
        sender_id: @sender.id,
        receiver_id: receiver_id,
        contact_id: nil,
        content: "#{@sender.login} appointed #{target_user.login} as moderator in #{@room.name}"
      )
    end
  end

  def notification_member_removed(removed_user, self_removal)
    removed_you!(removed_user) unless self_removal
    removed_for_others!(removed_user, self_removal)
  end

  def removed_you!(removed_user)
    Notification.create(
      sender_id: @sender.id,
      receiver_id: removed_user.id,
      contact_id: nil,
      content: "#{@sender.login} removed you from the conversation #{@room.name}"
    )
  end

  def removed_for_others!(removed_user, self_removal)
    recipient_ids = Room.find(@room.id).participants.pluck(:user_id) - [@sender.id]

    content =
      if self_removal
        "#{removed_user.login} left the conversation #{@room.name}"
      else
        "#{@sender.login} removed #{removed_user.login} from the conversation #{@room.name}"
      end

    recipient_ids.each do |receiver_id|
      Notification.create(
        sender_id: @sender.id,
        receiver_id: receiver_id,
        contact_id: nil,
        content: content
      )
    end
  end
end
