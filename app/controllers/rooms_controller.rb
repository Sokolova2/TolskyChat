# frozen_string_literal: true

class RoomsController < ApplicationController
  def index
    @rooms = Room.public_rooms
  end
end
