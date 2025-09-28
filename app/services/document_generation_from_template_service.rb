class DocumentGenerationFromTemplateService
  def initialize(template, user, current_user)
    @user = user
    @template = template
    @current_user = current_user
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
  rescue => e
    raise StandardError, e.message
  end

  private

  def create_empty_document
    @template.documents.create!(
      user: @current_user,
      template: @template,
      name: "#{@template.title} - #{@user[:name]}",
      description: "Documento gerado a partir do template: #{@template.title}",
      status: "pending_signature"
    )
  end

  def create_signer_for_document(document)
    document.signers.create(
      name: @user[:name],
      email: @user[:email],
      variables: @user[:variables],
      code: SecureRandom.uuid
    )
  end

  def generate_pdf_with_user_data
    html = <<~HTML
      <html>
        <head>
          <meta charset="utf-8">
          <style>
            /* Exemplo com Inter Regular embutida em Base64 */
            body {
              font-family: 'DejaVu Sans', Arial, sans-serif;
              font-size: 12pt;
              line-height: 0.7;
            }
            h1,h2,h3 { font-weight: 700; }
          </style>
        </head>
        <body>
          #{replace_variables_in_content}
        </body>
      </html>
    HTML
  
    WickedPdf.new.pdf_from_string(
      html,
      page_size: 'A4',
      margin: { top: 20, bottom: 20, left: 20, right: 20 },
      encoding: 'UTF-8'
    )
  end
  

  def replace_variables_in_content
    content = @template.content.dup
    
    @user[:variables].each do |key, value|
      placeholder = "{{#{key}}}"
      content.gsub!(placeholder, value.to_s)
    end

    content.gsub!("<p></p>", "<br>")

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