# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  root to: 'home#index'

  resources :conversations
  resources :contacts
  resources :users
  resources :notifications do
    member do
      delete :reject
    end
  end
end
