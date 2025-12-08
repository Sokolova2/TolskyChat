class MessagesController < ApplicationController
  def index
    @nofications = Notification.where()
  end
end
