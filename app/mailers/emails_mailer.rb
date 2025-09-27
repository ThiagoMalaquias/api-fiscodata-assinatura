class EmailsMailer < ApplicationMailer
  def send_document_to_signer(signer)
    @signer = signer
    @document = @signer.document

    mail(to: @signer.email, subject: "FiscoData - Assinatura Digital")
  end

  def send_document_to_reviewer(reviewer)
    @reviewer = reviewer
    @document = @reviewer.document

    mail(to: @reviewer.user.email, subject: "FiscoData - Assinatura Digital")
  end
end
