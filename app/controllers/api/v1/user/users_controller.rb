class Api::V1::User::UsersController < Api::V1::User::ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    @users = User.where(company_id: @current_user.company_id)
  end

  def show
  end

  def create
    @user = User.new(user_params)
    @user.company_id = @current_user.company_id

    if @user.save
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find_by(id: params[:id], company_id: @current_user.company_id)
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :role, :status, :password, :password_confirmation)
  end
end