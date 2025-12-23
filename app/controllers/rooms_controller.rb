# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    @conversations = Conversation
                       .joins(:participants)
                       .where(participants: { user_id: current_user.id })
                       .order(:created_at)

    @current_conversation = @conversations.first
  end
end
