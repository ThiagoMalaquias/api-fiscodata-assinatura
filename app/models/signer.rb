class Signer < ApplicationRecord
  has_one_attached :signature

  belongs_to :document

  after_update :verify_signatures, if: :saved_change_to_status?

  scope :pending, -> { where(status: "pending") }

  def send_document_to_signer
    EmailsMailer.send_document_to_signer(self).deliver
  end

  private

  def verify_signatures
    signers_pending = document.signers.where(status: "pending")
    document.update(status: "completed") if signers_pending.count.zero?
  end
end