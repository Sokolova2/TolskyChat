# frozen_string_literal: true

class RoomsController < ApplicationController
  def index
    @conversations = Conversation.all
  end
end
