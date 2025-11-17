require 'open3'
require 'open-uri'
require 'tempfile'

class PdfToDocxService
  class ConversionError < StandardError; end

  def initialize(pdf_url_or_path)
    @pdf_url_or_path = pdf_url_or_path
    @pdf_temp = nil
  end

  def call
    prepare_pdf_file
    convert_to_docx
  rescue => e
    raise ConversionError, "Erro ao converter PDF para DOCX: #{e.message}"
  ensure
    cleanup_temp_files
  end

  # Converte e retorna apenas o conteúdo binário do DOCX
  def convert
    call
  end

  # Converte e faz upload para S3, retornando a URL
  def convert_and_upload(output_filename)
    docx_content = call
    
    docx_temp = Tempfile.new(['docx', '.docx'])
    docx_temp.binmode
    docx_temp.write(docx_content)
    docx_temp.rewind

    begin
      upload_url = AwsService.upload(docx_temp.path, output_filename)
      upload_url
    ensure
      docx_temp.close!
    end
  end

  private

  def prepare_pdf_file
    if @pdf_url_or_path.start_with?('http')
      # Se for URL, baixa o arquivo temporariamente
      pdf_data = URI.open(@pdf_url_or_path).read
      @pdf_temp = Tempfile.new(['input', '.pdf'])
      @pdf_temp.binmode
      @pdf_temp.write(pdf_data)
      @pdf_temp.rewind
      @pdf_path = @pdf_temp.path
    else
      # Se for path local, usa diretamente
      @pdf_path = @pdf_url_or_path
      unless File.exist?(@pdf_path)
        raise ConversionError, "Arquivo PDF não encontrado: #{@pdf_path}"
      end
    end
  end

  def convert_to_docx
    output_dir = Dir.mktmpdir
    
    begin
      # Verifica se LibreOffice está instalado
      unless libreoffice_available?
        raise ConversionError, "LibreOffice não está instalado. Instale com: apt-get install libreoffice (Linux)"
      end

      # LibreOffice precisa de um diretório de saída
      # Usa modo headless para não precisar de interface gráfica
      cmd = "libreoffice --headless --convert-to docx --outdir '#{output_dir}' '#{@pdf_path}' 2>&1"
      stdout, stderr, status = Open3.capture3(cmd)

      unless status.success?
        error_msg = stderr.presence || stdout
        raise ConversionError, "LibreOffice falhou: #{error_msg}"
      end

      # Encontra o arquivo DOCX gerado (LibreOffice mantém o nome do arquivo original)
      docx_filename = File.basename(@pdf_path, '.pdf') + '.docx'
      docx_path = File.join(output_dir, docx_filename)

      # Se não encontrou com o nome esperado, procura qualquer arquivo .docx no diretório
      unless File.exist?(docx_path)
        docx_files = Dir.glob(File.join(output_dir, '*.docx'))
        if docx_files.empty?
          raise ConversionError, "Arquivo DOCX não foi gerado. LibreOffice output: #{stdout}"
        end
        docx_path = docx_files.first
      end

      # Lê o arquivo DOCX gerado
      docx_content = File.binread(docx_path)

      docx_content
    ensure
      FileUtils.rm_rf(output_dir) if output_dir && Dir.exist?(output_dir)
    end
  end

  def libreoffice_available?
    system('command -v libreoffice >/dev/null 2>&1')
  end

  def cleanup_temp_files
    @pdf_temp&.close!
  end
end