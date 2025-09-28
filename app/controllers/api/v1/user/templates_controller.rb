class Api::V1::User::TemplatesController < Api::V1::User::ApplicationController
  before_action :set_template, only: [:show, :update, :destroy]

  def index
    @templates = @current_user.templates
  end

  def show
  end

  def create
    @template = @current_user.templates.new(template_params)
    @template.variables = params[:template][:variables]

    if @template.save
      render json: @template
    else
      render json: @template.errors, status: :unprocessable_entity
    end
  end

  def update
    if @template.update(template_params)
      render json: @template
    else
      render json: @template.errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    @template.destroy
    head :no_content
  end

  private

  def set_template
    @template = Template.find(params[:id])
  end
  
  def template_params
    params.require(:template).permit(:title, :description, :content, :variables)
  end
end