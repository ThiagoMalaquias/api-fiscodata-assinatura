class Signer < ApplicationRecord
  belongs_to :document

  before_create :send_document_to_signer

  private

  def send_document_to_signer
    EmailsMailer.send_document_to_signer(self).deliver
  end
end