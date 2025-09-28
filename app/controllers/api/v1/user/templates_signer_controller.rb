class Api::V1::User::TemplatesSignerController < Api::V1::User::ApplicationController
  before_action :set_template

  def bulk_create
    template_users = TemplateUserBulkCreationService.new(@template, params[:users]).call
    results = TemplateBulkDocumentGenerationService.new(@template, template_users).call

    success_count = results.count { |r| r[:success] }
    error_count = results.count { |r| !r[:success] }

    render json: {
      message: "Processamento concluído",
      success_count: success_count,
      error_count: error_count,
      results: results
    }, status: :ok
    end

  private

  def set_template
    @template = @current_user.templates.find(params[:template_id])
  end
end