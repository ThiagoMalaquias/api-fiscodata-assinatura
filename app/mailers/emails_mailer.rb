class EmailsMailer < ApplicationMailer
  def send_document_to_signer(signer)
    @signer = signer
    @document = @signer.document

    mail(to: @signer.email, subject: "Assinatura Digital - #{@signer.name}")
  end
end
