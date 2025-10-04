class DocumentSignaturePageService
  def initialize(document)
    @document = document
  end

  def call
    return unless @document.completed?

    signatures_html = generate_signatures_page
    signatures_pdf  = WickedPdf.new.pdf_from_string(
      signatures_html,
      page_size: 'A4',
      margin:   { top: 20, bottom: 20, left: 20, right: 20 },
      encoding: 'UTF-8'
    )

    combine_pdfs(signatures_pdf)
  end

  private

  def generate_signatures_page
    signed_signers = @document.signers.where(status: 'signed')

    html =  +"<!DOCTYPE html>\n<html>\n<head>\n<meta charset='UTF-8'>\n"
    html <<  "<style>\n"
    html <<  <<~CSS
      body {
        font-family: 'DejaVu Sans', Arial, sans-serif;
        margin: 0;
        padding: 20px;
        font-size: 12pt;
        line-height: 1.45;
        color: #333;
      }
      .signatures-header {
        text-align: center;
        margin-bottom: 30px;
        border-bottom: 2px solid #333;
        padding-bottom: 20px;
      }
      .signatures-header h1 { margin: 0; font-size: 20pt; }
      .signatures-header p  { margin: 6px 0 0 0; color: #666; }
      .signature-item { margin-bottom: 40px; page-break-inside: avoid; }
      .signer-info   { margin-bottom: 12px; }
      .signer-name   { font-weight: 700; font-size: 14pt; color: #333; }
      .signer-email  { color: #666; font-size: 11pt; }
      .signature-image {
        border: 1px solid #ddd;
        max-width: 320px;
        max-height: 160px;
        margin-top: 8px;
        display: block;
      }
      .signature-date {
        color: #666;
        font-size: 10pt;
        margin-top: 6px;
      }
      .no-signature {
        color: #999;
        font-style: italic;
        margin-top: 8px;
      }
    CSS
    html <<  "</style>\n</head>\n<body>\n"

    html << <<~HTML
      <div class='signatures-header'>
        <h1>Assinaturas do Documento</h1>
        <p>#{h(@document.name)}</p>
        <p>Data de conclusão: #{Time.current.strftime('%d/%m/%Y às %H:%M')}</p>
      </div>
    HTML

    signed_signers.find_each do |signer|
      html << "<div class='signature-item'>\n"
      html << "  <div class='signer-info'>\n"
      html << "    <div class='signer-name'>#{h(signer.name)}</div>\n"
      html << "    <div class='signer-email'>#{h(signer.email)}</div>\n"
      html << "  </div>\n"

      if signer.signature.attached?
        blob = signer.signature.blob
        mime = blob.content_type.presence || mime_from_filename(blob.filename.to_s) || "image/png"
        data = Base64.strict_encode64(blob.download) # sem quebras

        html << %Q(  <img src="data:#{mime};base64,#{data}" class="signature-image" alt="Assinatura de #{h(signer.name)}">\n)
      else
        html << %Q(  <div class="no-signature">Assinatura não disponível</div>\n)
      end

      signed_at = signer.signature_at&.strftime('%d/%m/%Y às %H:%M') || 'Data não disponível'
      html << %Q(  <div class="signature-date">Assinado em: #{signed_at}</div>\n)
      html << "</div>\n"
    end

    html << "</body>\n</html>\n"
    html
  end

  def combine_pdfs(signatures_pdf)
    original_pdf   = to_binary(@document.file.download)
    signatures_pdf = to_binary(signatures_pdf)

    pdf_binary =
      begin
        combine_with_combine_pdf(original_pdf, signatures_pdf)
      rescue => e
        Rails.logger.warn("[DocumentSignaturePageService] CombinePDF falhou (#{e.class}): #{e.message}")
        if qpdf_available?
          combine_with_qpdf(original_pdf, signatures_pdf)
        else
          raise
        end
      end

    attach_combined_pdf(pdf_binary)
  end

  def combine_with_combine_pdf(original_pdf, signatures_pdf)
    require 'combine_pdf'
    combined = CombinePDF.new
    combined << CombinePDF.parse(original_pdf)
    combined << CombinePDF.parse(signatures_pdf)
    combined.to_pdf
  end

  def qpdf_available?
    system('command -v qpdf >/dev/null 2>&1')
  end

  def combine_with_qpdf(original_pdf, signatures_pdf)
    require 'shellwords'
    Tempfile.create(['orig', '.pdf']) do |orig|
      Tempfile.create(['signs', '.pdf']) do |signs|
        Tempfile.create(['out',  '.pdf']) do |out|
          [orig, signs, out].each(&:binmode)
          orig.write(original_pdf);  orig.flush
          signs.write(signatures_pdf); signs.flush

          cmd = [
            'qpdf', '--empty', '--pages',
            Shellwords.escape(orig.path),
            Shellwords.escape(signs.path),
            '--',
            Shellwords.escape(out.path)
          ].join(' ')

          system(cmd)
          raise "qpdf failed (exit #{$?.exitstatus})" unless $?.success?

          out.rewind
          return out.read
        end
      end
    end
  end

  def attach_combined_pdf(pdf_binary)
    io = StringIO.new(pdf_binary)
    @document.file.attach(
      io: io,
      filename: "#{sanitize_filename(@document.name)}_assinado.pdf",
      content_type: 'application/pdf'
    )
  end

  def to_binary(str)
    s = str.dup
    s.force_encoding(Encoding::BINARY)
    s
  end

  def sanitize_filename(name)
    base = name.to_s.strip
    base = 'document' if base.empty?
    base.gsub(/[^\w.\-]+/, '_')[0, 120]
  end

  def h(text)
    ERB::Util.html_escape(text.to_s)
  end

  def mime_from_filename(filename)
    case File.extname(filename).downcase
    when '.png'        then 'image/png'
    when '.jpg', '.jpeg' then 'image/jpeg'
    when '.gif'        then 'image/gif'
    else nil
    end
  end
end
