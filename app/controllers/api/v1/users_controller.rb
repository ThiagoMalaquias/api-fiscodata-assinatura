class Api::V1::UsersController < Api::V1::ApplicationController
  def create
    @user = User.new(user_params)
    @user.role = "manager"

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