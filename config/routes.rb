# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  mount ActionCable.server => '/cable'
  get '/turn_credentials', to: 'turn_credentials#show'

  root to: 'home#index'

  resources :rooms do
    resources :messages
    collection do
      get :public_search
    end
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

  get 'archive', to: 'rooms#archive'
end
