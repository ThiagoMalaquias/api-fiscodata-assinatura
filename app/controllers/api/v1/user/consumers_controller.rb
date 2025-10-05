class Api::V1::User::ConsumersController < Api::V1::User::ApplicationController
  before_action :set_consumer, only: [:show, :update, :destroy]

  def index
    @consumers = Consumer.where(company_id: @current_user.company_id)
                        .order(created_at: :desc)
                        .paginate(page: params[:page], per_page: 10)
  end

  def get_by_cpf_cnpj
    @consumers = Consumer.where(company_id: @current_user.company_id)
    @consumer = nil
  
    if params[:search].present?
      @consumer = @consumers.find_by(cpf: params[:search])
      @consumer = @consumers.find_by(cnpj: params[:search]) if @consumer.nil?
    end

    if @consumer.nil?
      render json: { error: "Consumidor não encontrado" }, status: :not_found
      return
    end

    render json: @consumer
  end

  def show
  end

  def create
    @consumer = Consumer.new(consumer_params)
    @consumer.company_id = @current_user.company_id

    if @consumer.save
      render json: @consumer
    else
      render json: @consumer.errors, status: :unprocessable_entity
    end
  end
  
  def update
    if @consumer.update(consumer_params)
      render json: @consumer
    else
      render json: @consumer.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @consumer.destroy
    head :no_content
  end

  private
  
  
  def set_consumer
    @consumer = Consumer.find_by(id: params[:id], company_id: @current_user.company_id)
  end

  def consumer_params
    params.require(:consumer).permit(:name, :email, :phone, :cpf, :cnpj)
  end
end