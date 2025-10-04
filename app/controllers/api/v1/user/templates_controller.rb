class Api::V1::User::TemplatesController < Api::V1::User::ApplicationController
  before_action :set_template, only: [:show, :update, :destroy, :bulk_create]

  def index
    @templates = @current_user.templates
                            .order(created_at: :desc)
                            .paginate(page: params[:page], per_page: 10)
  end

  def show
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