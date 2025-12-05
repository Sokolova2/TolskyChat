class ContactsController < ApplicationController
  before_action :set_contact, only: %i[show update destroy]

  def index
    @contacts = Contact.all
  end

  def show; end

  def create
    @new_contact = Contact.create(sender_id: current_user.id, receiver_id: params[:receiver_id])

    if @new_contact.save
      redirect_to contacts_path
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

    if @contact.sender_id == current_user.id
      @user = @contact.receiver
    else
      @user = @contact.sender
    end
  end
end
