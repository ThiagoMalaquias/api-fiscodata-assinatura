class Api::V1::ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :validate_token
  
  def validate_token
    token = request.headers["authorization"].to_s.gsub("Bearer ", "") rescue ""
    payload, = JWT.decode(token, Rails.application.credentials.secret_key_base)
    @user = User.find(payload["user_id"])
    return if @user.present?

    return render json: { error: "Token expirado" }, status: :unauthorized
  rescue
    return render json: { error: "Token inválido" }, status: :unauthorized
  end
end