class DocumentCreationService
  def initialize(user, document_params, params_reviewer, params_signers)
    @user = user
    @document_params = document_params
    @reviewer_data = extract_reviewer_data(params_reviewer)
    @signers_data = extract_signers_data(params_signers)
  end

  def call
    ActiveRecord::Base.transaction do
      create_document
      create_reviewer if @reviewer_data
      create_signers if @signers_data
      send_initial_notifications

      @document
    end
  rescue StandardError => e
    raise StandardError, e.message
  end

  private

  def create_document
    @document = @user.documents.create!(@document_params)
  end

  def create_reviewer
    return if @reviewer_data.blank? || @reviewer_data == "null"

    @document.create_reviewer!(user_id: @reviewer_data["id"])
  end

  def create_signers
    return if @signers_data.blank?

    @signers_data.each do |signer_data|
      @document.signers.create!(
        name: signer_data["name"],
        email: signer_data["email"],
        role: signer_data["role"],
        code: SecureRandom.uuid
      )
    end
  end

  def send_initial_notifications
    if @document.reviewer.present?
      @document.update(status: "pending_review")
      send_reviewer_notification
    else
      @document.update(status: "pending_signature")
      send_signers_notifications
    end
  end

  def send_reviewer_notification
    EmailsMailer.send_document_to_reviewer(@document.reviewer).deliver
  end

  def send_signers_notifications
    @document.signers.each do |signer|
      signer.send_document_to_signer
    end
  end

  def extract_reviewer_data(params_reviewer)
    JSON.parse(params_reviewer) if params_reviewer.present?
  rescue JSON::ParserError
    nil
  end

  def extract_signers_data(params_signers)
    JSON.parse(params_signers) if params_signers.present?
  rescue JSON::ParserError
    []
  end
end