json.extract! document, :id, :name, :description, :status, :deadline_at, :created_at

if document.file.attached?
  json.file rails_blob_url(document.file)
  json.size document.file.byte_size
  json.type document.file.content_type
end 

json.signers document.signers.each do |signer|
  json.extract! signer, :id, :name, :email, :role, :status
end

if document.reviewer
  json.reviewer do
    json.id document.reviewer.id
    json.user_id document.reviewer.user.id
    json.user_name document.reviewer.user.name
    json.user_email document.reviewer.user.email
    json.status document.reviewer.status
  end
end

