class Api::V1::CompaniesController < Api::V1::ApplicationController
  def create
    @company = Company.new(company_params)
    if @company.save
      render json: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.require(:company).permit(:name, :email, :phone, :address, :number, :neighborhood, :city, :state, :zip_code)
  end
end


