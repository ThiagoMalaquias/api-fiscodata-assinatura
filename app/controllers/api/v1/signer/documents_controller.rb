class Api::V1::Signer::DocumentsController < Api::V1::Signer::ApplicationController
  before_action :set_document, only: [:show, :update, :destroy]

  def index
    @documents = Document.all
  end

  def show
  end

  def create
    @document = @current_user.documents.new(document_params)
    if @document.save
      document_reviewer
      document_signers

      render json: @document.as_json(except: [:file], include: [:reviewer, :signers]), status: :created
    else
      render json: { errors: @document.errors }, status: :unprocessable_entity
    end
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

  def document_reviewer
    if params[:document][:reviewer] && params[:document][:reviewer] != "null"
      reviewer_data = JSON.parse(params[:document][:reviewer])
      Reviewer.create(document_id: @document.id, user_id: reviewer_data["id"])
    end
  end

  def document_signers
    if params[:document][:signers]
      signers_data = JSON.parse(params[:document][:signers])
      signers_data.each do |signer|
        @document.signers.create(
          name: signer["name"], 
          email: signer["email"], 
          role: signer["role"],
          code: SecureRandom.uuid
        )
      end
    end
  end

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:name, :description, :file, :deadline_at)
  end
end