require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  # sidekiq server
  mount Sidekiq::Web => '/sidekiq'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      namespace :user do
        resources :auth do
          post :login, on: :collection
        end

        resources :users
        resources :companies
        resources :signatures
        resources :documents
        resources :templates
      end

      namespace :signer do
        resources :auth do
          post :login, on: :collection
        end

        resources :documents
      end

      resources :signers do
        get "document/:code", on: :collection, action: :document
        post "document/:code/sign", on: :collection, action: :sign
        post "document/:code/reject", on: :collection, action: :reject
      end
    end
  end

  root to: "home#index"
end
