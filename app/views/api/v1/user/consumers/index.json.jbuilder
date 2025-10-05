json.consumers @consumers do |consumer|
  json.partial! "api/v1/user/consumers/consumer", consumer: consumer
end

json.pagination do
  json.current_page @consumers.current_page
  json.total_pages @consumers.total_pages
  json.total_entries @consumers.total_entries
  json.per_page @consumers.per_page
  json.has_next_page @consumers.next_page.present?
  json.has_previous_page @consumers.previous_page.present?
  
  if @consumers.next_page.present?
      json.next_page @consumers.next_page
  end
  
  if @consumers.previous_page.present?
    json.previous_page @consumers.previous_page
  end
end