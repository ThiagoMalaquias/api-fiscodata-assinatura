json.templates @templates do |template|
  json.partial! "api/v1/user/templates/template", template: template
end

json.pagination do
  json.current_page @templates.current_page
  json.total_pages @templates.total_pages
  json.total_entries @templates.total_entries
  json.per_page @templates.per_page
  json.has_next_page @templates.next_page.present?
  json.has_previous_page @templates.previous_page.present?
  
  if @templates.next_page.present?
    json.next_page @templates.next_page
  end
  
  if @templates.previous_page.present?
    json.previous_page @templates.previous_page
  end
end