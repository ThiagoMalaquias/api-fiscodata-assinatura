class Api::V1::User::DocumentsController < Api::V1::User::ApplicationController
  before_action :set_document, only: [:show, :update, :destroy, :approve, :reject]

  def index
    @documents = Document.left_joins(:reviewer)
                        .where(
                          "documents.user_id = ? OR reviewers.user_id = ?",
                          @current_user.id, @current_user.id
                        )
                        .order(created_at: :desc)
  end

  def show
  end

  def approve
    if @document.reviewer.approve!
      render json: { message: "Documento aprovado com sucesso" }, status: :ok
    else
      render json: { errors: @document.reviewer.errors }, status: :unprocessable_entity
    end
  end

  def reject
    if @document.reviewer.reject!
      render json: { message: "Documento rejeitado" }, status: :ok
    else
      render json: { errors: @document.reviewer.errors }, status: :unprocessable_entity
    end
  end

  def create
    service = DocumentCreationService.new(@current_user, document_params, params[:document][:reviewer], params[:document][:signers])
    @document = service.call

    if @document.nil?
      render json: { errors: "Erro ao criar documento" }, status: :unprocessable_entity
      return
    end
    
    render json: @document.as_json(except: [:file], include: [:reviewer]), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors }, status: :unprocessable_entity
  end

  def update
    if @document.update(document_params)
      render json: @document
    end
  end

  def destroy
    @document.destroy
    head :no_content
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:name, :description, :file, :deadline_at)
  end
end