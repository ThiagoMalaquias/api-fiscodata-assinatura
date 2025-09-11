require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  # sidekiq server
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      resources :auth do
        post :login, on: :collection
      end

      resources :users
      resources :companies
      resources :signatures
      resources :documents
      resources :templates
    end
  end

  root to: "home#index"
end
