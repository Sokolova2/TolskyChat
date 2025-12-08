# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    before_action :configure_account_update_params, only: [:update]

    def create
      super
    end

    def update
      super
    end

    protected
    def after_sign_up_path_for(resource)
      root_path
    end

    def after_update_path_for(resource)
      conversations_path
    end

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name login phone_number birth_date avatar description])
    end

    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name login phone_number birth_date avatar description])
    end

    def update_resource(resource, params)
      if resource.encrypted_password.blank?
        resource.update_without_password(account_update_params.except(:current_password))
      end
      if params[:password].present? && params[:password_confirmation].present?
        resource.update_with_password(account_update_params)
      else
        resource.update_without_password(account_update_params.except(:current_password))
      end
    end
  end
end

