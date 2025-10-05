json.array! @template_folders do |template_folder|
  json.partial! 'api/v1/user/template_folders/template_folder_tree', template_folder: template_folder
end