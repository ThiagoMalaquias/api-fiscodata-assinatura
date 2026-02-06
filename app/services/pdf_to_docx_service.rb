require 'open3'
require 'open-uri'
require 'tempfile'
require 'fileutils'
require 'tmpdir'
require 'uri'

class PdfToDocxService
  class ConversionError < StandardError; end

  def initialize(pdf_url_or_path)
    @pdf_url_or_path = pdf_url_or_path.to_s
    @pdf_temp = nil
    @pdf_path = nil
  end

  def call
    prepare_pdf_file
    convert_to_docx
  rescue ConversionError
    raise
  rescue => e
    raise ConversionError, "Erro ao converter PDF para DOCX: #{e.message}"
  ensure
    cleanup_temp_files
  end

  def convert
    call
  end

  def convert_and_upload(output_filename)
    docx_content = call

    docx_temp = Tempfile.new(['output', '.docx'])
    docx_temp.binmode
    docx_temp.write(docx_content)
    docx_temp.rewind

    begin
      AwsService.upload(docx_temp.path, output_filename)
    ensure
      docx_temp.close!
    end
  end

  private

  def prepare_pdf_file
    if http_url?(@pdf_url_or_path)
      pdf_data = URI.open(
        @pdf_url_or_path,
        open_timeout: 10,
        read_timeout: 60
      ).read

      @pdf_temp = Tempfile.new(['input', '.pdf'])
      @pdf_temp.binmode
      @pdf_temp.write(pdf_data)
      @pdf_temp.rewind
      @pdf_path = @pdf_temp.path
    else
      @pdf_path = @pdf_url_or_path
      raise ConversionError, "Arquivo PDF não encontrado: #{@pdf_path}" unless File.exist?(@pdf_path)
    end
  end

  def convert_to_docx
    output_dir = Dir.mktmpdir

    begin
      soffice = libreoffice_command
      raise ConversionError, "LibreOffice não está instalado (libreoffice/soffice não encontrado)." unless soffice

      stdout, stderr, status = Open3.capture3(
        soffice,
        "--headless",
        "--nologo",
        "--nofirststartwizard",
        "--convert-to", "docx",
        "--outdir", output_dir,
        @pdf_path.to_s
      )

      unless status.success?
        err = (stderr && !stderr.empty?) ? stderr : stdout
        raise ConversionError, "LibreOffice falhou: #{err}"
      end

      docx_files = Dir.glob(File.join(output_dir, "*.docx"))
      raise ConversionError, "Arquivo DOCX não foi gerado. Output: #{stdout}" if docx_files.empty?

      File.binread(docx_files.first)
    ensure
      FileUtils.rm_rf(output_dir) if output_dir && Dir.exist?(output_dir)
    end
  end

  def libreoffice_command
    return "libreoffice" if system("command -v libreoffice >/dev/null 2>&1")
    return "soffice"     if system("command -v soffice >/dev/null 2>&1")
    nil
  end

  def http_url?(value)
    uri = URI.parse(value)
    uri.is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  def cleanup_temp_files
    @pdf_temp&.close!
  end
end
