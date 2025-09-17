class Api::V1::Signer::AuthController < Api::V1::Signer::ApplicationController
  skip_before_action :validate_token
  
  def login
    user = User.find_by(email: params[:email])
    if user && user.valid_password?(params[:password])
      render json: { user: user, token: JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base) }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end