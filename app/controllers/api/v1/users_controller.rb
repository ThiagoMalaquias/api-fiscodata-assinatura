class Api::V1::UsersController < Api::V1::ApplicationController
  def create
    user_exists = User.find_by(email: user_params[:email])
    if user_exists.present?
      return render json: { error: "Email já esta em uso" }, status: :unprocessable_entity
    end

    @user = User.new(user_params)
    @user.role = "manager"
    @user.company_id = params[:company_id]

    if @user.save
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end