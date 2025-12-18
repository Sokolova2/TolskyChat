# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    @conversations = Conversation
                       .joins(:participants)
                       .where(participants: { user_id: current_user.id })
  end
end
