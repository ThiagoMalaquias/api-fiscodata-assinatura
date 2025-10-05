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

        resources :users do
          get :me, on: :collection
        end

        resources :companies
        resources :signatures
        resources :consumers do
          get :get_by_cpf_cnpj, on: :collection
        end

        resources :templates do
          post :bulk_create, on: :member
        end

        resources :documents do
          member do
            patch :approve
            patch :reject
          end
        end

        resources :dashboard do
          get :recent_documents, on: :collection
          get :review_documents, on: :collection
        end
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

      resources :users
      resources :companies
    end
  end

  root to: "home#index"
end
