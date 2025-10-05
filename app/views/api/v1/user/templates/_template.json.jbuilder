json.extract! template, :id, :title, :description, :created_at
json.documents_count template.documents.count
json.variables template.variables || []

