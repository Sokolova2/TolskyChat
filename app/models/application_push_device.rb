# frozen_string_literal: true

class ApplicationPushDevice < ActionPushNative::Device
  belongs_to :user
end
