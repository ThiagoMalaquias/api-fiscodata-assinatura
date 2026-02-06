class Api::V1::User::TemplatesController < Api::V1::User::ApplicationController
  skip_before_action :validate_token, only: [:show_pdf]
  before_action :set_template, only: [:show, :update, :destroy, :bulk_create, :move_to_folder, :move_to_back_folder, :show_pdf, :download_docx]

  def index
    @templates = @current_user.templates.where(template_folder_id: nil)
  end

  def show
  end

  def download_docx
    unless @template.file_docx.present?
      return render json: { error: 'Arquivo DOCX não encontrado' }, status: :not_found
    end

    begin
      if @template.file_docx.start_with?('http')
        require 'open-uri'

        file_data = URI.open(@template.file_docx)

        send_data file_data.read,
                  filename: "#{@template.title || 'documento'}.docx",
                  type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                  disposition: 'inline'
      else
        if @template.file_docx.attached?
          @template.file_docx.download do |chunk|
            response.stream.write chunk
          end
          response.stream.close
        else
          render json: { error: 'Arquivo não encontrado' }, status: :not_found
        end
      end
    rescue => e
      Rails.logger.error "Erro ao baixar DOCX: #{e.message}"
      render json: { error: 'Erro ao baixar arquivo' }, status: :internal_server_error
    end
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

  def show_pdf    
    pdf_url = @template.file_pdf
    
    pdf_data = AwsService.get(pdf_url)
    
    send_data pdf_data, 
      type: 'application/pdf', 
      disposition: 'inline',
      filename: 'template.pdf'
  end

  def create
    @template = @current_user.templates.new(template_params)
    @template.variables = params[:template][:variables]
    upload_file
   
    if @template.save
      render json: @template
    else
      render json: @template.errors, status: :unprocessable_entity
    end
  end

  def update
    if @template.update(template_params)
      upload_file
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

  def upload_file
    if params[:file_docx].present? && params[:template][:file_docx] == "true"
      @template.file_docx = AwsService.upload(
        params[:file_docx].tempfile.path, 
        params[:file_docx].original_filename
      )
    end
    
    if params[:file_pdf].present? && params[:template][:file_pdf] == "true"
      pdf_url = AwsService.upload(
        params[:file_pdf].tempfile.path, 
        params[:file_pdf].original_filename
      )
      @template.file_pdf = pdf_url
    end
  end

  def set_template
    @template = Template.find(params[:id])
  end
  
  def template_params
    params.require(:template).permit(:title, :description, :content, :variables, :template_folder_id)
  end
end