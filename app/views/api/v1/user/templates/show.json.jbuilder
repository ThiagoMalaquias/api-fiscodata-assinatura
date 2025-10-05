json.extract! @template, :id, :title, :description, :content, :created_at
json.variables @template.variables || []