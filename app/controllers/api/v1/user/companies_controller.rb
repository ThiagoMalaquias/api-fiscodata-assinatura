class Api::V1::User::CompaniesController < Api::V1::User::ApplicationController
  skip_before_action :validate_token, only: [:create]
  before_action :set_company, only: [:show, :update, :destroy]

  def index
    @companies = Company.all
    render json: @companies
  end

  def show
    render json: @company
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      render json: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  def update
    if @company.update(company_params)
      render json: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :email, :phone, :address, :number, :neighborhood, :city, :state, :zip_code)
  end
end


