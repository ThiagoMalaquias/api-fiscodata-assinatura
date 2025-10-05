class Api::V1::User::TemplatesController < Api::V1::User::ApplicationController
  before_action :set_template, only: [:show, :update, :destroy, :bulk_create, :move_to_folder, :move_to_back_folder]

  def index
    @templates = @current_user.templates.where(template_folder_id: nil)
  end

  def show
  end

  def move_to_folder
    @template.update(template_folder_id: params[:template][:template_folder_id])
    render json: { message: "Template movido para a pasta" }, status: :ok
  end

  def move_to_back_folder
    @template.update(template_folder_id: @template.template_folder.origin_id)
    render json: { message: "Template movido para a pasta" }, status: :ok
  end

  def bulk_create
    results = TemplateBulkDocumentGenerationService.new(@template, params[:users], @current_user).call

    success_count = results.count { |r| r[:success] }
    error_count = results.count { |r| !r[:success] }

    render json: {
      message: "Processamento concluído",
      success_count: success_count,
      error_count: error_count,
    }, status: :ok
  rescue => e
    render json: { errors: e.message }, status: :unprocessable_entity
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
      @template.variables = params[:template][:variables]
      @template.save
      
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
    params.require(:template).permit(:title, :description, :content, :variables, :template_folder_id)
  end
end