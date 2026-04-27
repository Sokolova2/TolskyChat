# frozen_string_literal: true

class PersonalChatsController < ApplicationController
  before_action :set_chat, only: :show
  before_action :set_participants, only: :show
  before_action :set_chats, only: %i[index show]

  def index; end

  def create
    second_user = User.find(personal_chat_params[:second_user_id])
    @personal_chat_new = RoomService.new(current_user).call_chat(second_user)

    if @personal_chat_new.persisted?
      respond_to do |format|
        format.turbo_stream
        format.html {redirect_to personal_chat_path(@personal_chat_new)}
      end
    else
      redirect_to personal_chat_path, alert: @personal_chat_new.errors.full_messages.to_sentence
    end
  end

  def destroy; end

  private

  def personal_chat_params
    params.require(:personal_chat).permit(:name, :is_private, :deleted_at, :second_user_id, participants_attributes: [:user_id, :role])
  end

  def set_chats
    @conversations = Room.all
  end
end
