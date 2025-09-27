class Api::V1::User::DashboardController < Api::V1::User::ApplicationController
  def index
    @document_count = @current_user.documents.count
    @completed_document_count = @current_user.documents.where(status: "completed").count
    @signer_count = Signer.where(document: @current_user.documents).pending.count
    @tax_document_completed_count = ((@completed_document_count * 100) / @document_count).to_i.round(0) rescue 0

    render json: {
      document_count: @document_count,
      completed_document_count: @completed_document_count,
      signer_count: @signer_count,
      tax_document_completed_count: @tax_document_completed_count
    }, status: :ok
  end

  def review_documents
    @review_count = Document.includes(:reviewer).where(reviewer: { status: "pending", user_id: @current_user.id }).count

    render json: {
      review_count: @review_count
    }, status: :ok
  end

  def recent_documents
    @documents = @current_user.documents.includes(:signers).order(created_at: :desc).limit(5)
  end
end