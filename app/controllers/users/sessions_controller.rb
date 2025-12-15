# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def after_sign_out_path_for(_resource_or_scope)
      root_path
    end

    def after_sign_in_path_for(_resource_or_scope)
      rooms_path
    end
  end
end
