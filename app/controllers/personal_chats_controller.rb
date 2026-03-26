# frozen_string_literal: true

class PersonalChatsController < ApplicationController
  def index; end

  def show; end

  def create

  end

  def destroy

  end
end

=begin
def create
  @conversation_new = RoomService.new(conversation_params, current_user).call

  if @conversation_new.save
    respond_to do |format|
      format.turbo_stream
      format.html {redirect_to conversations_path}
    end
  else
    redirect_to new_conversation_path, alert: @conversation_new.errors.full_messages.to_sentence
  end
end=end
