json.users @users do |user|
  json.partial! "api/v1/user/users/user", user: user
end

json.pagination do
  json.current_page @users.current_page
  json.total_pages @users.total_pages
  json.total_entries @users.total_entries
  json.per_page @users.per_page
  json.has_next_page @users.next_page.present?
  json.has_previous_page @users.previous_page.present?
  
  if @users.next_page.present?
    json.next_page @users.next_page
  end
  
  if @users.previous_page.present?
    json.previous_page @users.previous_page
  end
end