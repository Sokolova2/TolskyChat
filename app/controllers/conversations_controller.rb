# frozen_string_literal: true

class ConversationsController < ApplicationController
  def index
    @contacts = Contact.all
  end
end
