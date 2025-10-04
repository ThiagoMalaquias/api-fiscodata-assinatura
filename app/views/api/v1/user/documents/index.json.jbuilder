json.documents @documents do |document|
  json.partial! "api/v1/user/documents/document", document: document
end

json.pagination do
  json.current_page @documents.current_page
  json.total_pages @documents.total_pages
  json.total_entries @documents.total_entries
  json.per_page @documents.per_page
  json.has_next_page @documents.next_page.present?
  json.has_previous_page @documents.previous_page.present?
  
  if @documents.next_page.present?
    json.next_page @documents.next_page
  end
  
  if @documents.previous_page.present?
    json.previous_page @documents.previous_page
  end
end