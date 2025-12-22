# frozen_string_literal: true

class ContactsController < ApplicationController
  before_action :set_contact, only: %i[show update destroy]

  def index
    @contacts = Contact
                .where(approved: true)
                .where('sender_id = :id OR receiver_id = :id', id: current_user.id)
                .joins('JOIN users ON users.id = contacts.receiver_id')
                .where(users: { deleted_at: nil })
  end

  def show; end

  def create
    @new_contact = Contact.new(sender_id: current_user.id, receiver_id: params[:receiver_id])

    if @new_contact.save
      create_notification
      redirect_to users_path
    else
      redirect_to users_path, alert: @new_contact.errors.full_messages
    end
  end

  def update
    @update_contact = @contact.update(blocked: params[:blocked])

    redirect_to contacts_path
  end

  def destroy
    @contact.destroy

    redirect_to contacts_path
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])

    @user = if @contact.sender_id == current_user.id
              @contact.receiver
            else
              @contact.sender
            end
  end

  def create_notification
    Notification.create(
      sender_id: current_user.id,
      receiver_id: @new_contact.receiver_id,
      contact_id: @new_contact.id,
      content: 'You have received a friend request'
    )
  end
end
