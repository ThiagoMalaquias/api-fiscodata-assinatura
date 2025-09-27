class Reviewer < ApplicationRecord
  belongs_to :document
  belongs_to :user

  enum status: {
    pending: "pending",
    approved: "approved", 
    rejected: "rejected"
  }

  after_update :send_document_to_signers, if: :saved_change_to_status?

  def approve!
    update!(status: "approved")
    document.update(status: "pending_signature")
  end

  def reject!
    update!(status: "rejected")
    document.update(status: "rejected")
  end

  private

  def send_document_to_signers
    return unless approved?
    
    document.signers.each do |signer|
      signer.send_document_to_signer
    end
  end
end