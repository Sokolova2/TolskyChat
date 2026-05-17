# frozen_string_literal: true

class ContactsController < ApplicationController
  before_action :set_contact, only: %i[show update destroy]
  before_action :new_contact_params, only: :create

  def index
    @contacts = Contact.user_contacts(current_user.id)
  end

  def show; end

  def create
    if @new_contact.save
      create_notification
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to users_path }
      end
    else
      redirect_to users_path, alert: @new_contact.errors.full_messages
    end
  end

  def update
    blocked = ActiveModel::Type::Boolean.new.cast(params[:blocked])

    @update_contact = @contact.update(blocked: params[:blocked],
                                      blocked_by_id: blocked ? current_user.id : nil)

    redirect_to contacts_path
  end

  def destroy
    @contact.destroy
    @contacts = Contact.user_contacts(current_user.id)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to contacts_path, notice: 'Contact was successfully destroyed.' }
    end
  end

  private

  def new_contact_params
    @new_contact = Contact.new(sender_id: current_user.id, receiver_id: params[:receiver_id])
    @user = User.find(params.expect(:receiver_id))
  end

  def set_contact
    @contact = Contact.find(params.expect(:id))

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
