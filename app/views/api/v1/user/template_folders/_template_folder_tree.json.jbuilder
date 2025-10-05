json.extract! template_folder, :id, :name, :created_at, :updated_at

json.templates template_folder.templates do |template|
  json.partial! 'api/v1/user/templates/template', template: template
end

if template_folder.sub_folders.any?
  json.subfolders template_folder.sub_folders.order(:name) do |subfolder|
    json.partial! 'api/v1/user/template_folders/template_folder_tree', template_folder: subfolder
  end
else
  json.subfolders []
end

