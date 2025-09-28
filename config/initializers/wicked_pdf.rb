WickedPdf.config = {
  exe_path: Rails.env.production? ? '/usr/local/bin/wkhtmltopdf' : `which wkhtmltopdf`.strip
}