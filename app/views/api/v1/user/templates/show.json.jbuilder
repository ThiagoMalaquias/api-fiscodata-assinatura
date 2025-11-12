json.extract! @template, :id, :title, :description, :content, :file_pdf, :file_docx, :created_at
json.variables @template.variables || []