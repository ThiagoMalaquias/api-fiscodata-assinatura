json.extract! template_folder, :id, :name, :origin_id, :created_at, :updated_at

json.templates template_folder.templates do |template|
  json.partial! 'api/v1/user/templates/template', template: template
end

