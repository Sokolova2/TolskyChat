# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def unread_digest(user, notifications)
    @user = user
    @notifications = notifications
    mail(to: @user.email, subject: 'You have unread notifications in TolskyChat. Check it https://tolskychat-2df8101d6866.herokuapp.com/')
  end
end
