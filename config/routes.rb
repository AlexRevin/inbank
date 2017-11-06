# frozen_string_literal: true


Rails.application.routes.draw do
  resources :calculators, only: [:index, :create]
  namespace :admin do
    resources :users
    root to: 'users#index'
  end
  root to: 'calculators#index'
  devise_for :users
  resources :users
end
