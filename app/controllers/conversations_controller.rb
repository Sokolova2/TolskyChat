class ConversationsController < ApplicationController
  def index
    @contacts = Contact.all
  end
end
