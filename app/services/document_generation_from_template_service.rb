class DocumentGenerationFromTemplateService
  def initialize(template_user)
    @template_user = template_user
    @template = template_user.template
  end

  def call
    ActiveRecord::Base.transaction do
      document = create_empty_document
      signer = create_signer_for_document(document)
      pdf_content = generate_pdf_with_user_data
      
      update_document_file(document, pdf_content)
      send_for_signature(signer)
      
      document
    end
  end

  private

  def create_empty_document
    @template.user.documents.create!(
      name: "#{@template.title} - #{@template_user.name}",
      description: "Documento gerado a partir do template: #{@template.title}",
      status: "pending_signature"
    )
  end

  def create_signer_for_document(document)
    document.signers.create!(
      name: @template_user.name,
      email: @template_user.email,
      role: @template_user.role,
      code: SecureRandom.uuid
    )
  end

  def generate_pdf_with_user_data
    processed_html = replace_variables_in_content
    
    WickedPdf.new.pdf_from_string(
      processed_html,
      page_size: 'A4',
      margin: { top: 20, bottom: 20, left: 20, right: 20 },
      encoding: 'UTF-8'
    )
  end

  def replace_variables_in_content
    content = @template.content.dup
    
    @template_user.variables.each do |key, value|
      placeholder = "{{#{key}}}"
      content.gsub!(placeholder, value.to_s)
    end
    
    content
  end

  def update_document_file(document, pdf_content)
    temp_file = Tempfile.new(['document', '.pdf'])
    temp_file.binmode
    temp_file.write(pdf_content)
    temp_file.rewind

    document.file.attach(
      io: temp_file,
      filename: "#{document.name}.pdf",
      content_type: 'application/pdf'
    )
  end

  def send_for_signature(signer)
    signer.send_document_to_signer
  end
end