class Api::V1::ApplicationController < ActionController::API
  include ActionController::RequestForgeryProtection
  protect_from_forgery with: :null_session
  skip_forgery_protection
end