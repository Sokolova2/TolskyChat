# frozen_string_literal: true

class RoomsController < ApplicationController
  def index
    @conversations = Conversation
                       .joins(:participants)
                       .where(participants: { user_id: current_user.id })
  end
end
