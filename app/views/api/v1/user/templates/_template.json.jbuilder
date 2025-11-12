json.extract! template, :id, :title, :description, :file_pdf, :file_docx, :created_at
json.documents_count template.documents.count
json.variables template.variables || []

