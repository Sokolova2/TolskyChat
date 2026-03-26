# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  mount ActionCable.server => '/cable'

  root to: 'home#index'

  resources :rooms do
    resources :messages
  end

  resources :conversations

  resources :personal_chats
  resources :contacts
  resources :users
  resources :participants
  resources :notifications do
    member do
      delete :reject
    end
  end
end
