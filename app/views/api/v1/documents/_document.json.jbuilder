json.extract! document, :id, :name, :description, :status, :deadline_at, :created_at

json.file rails_blob_url(document.file)
json.size document.file.byte_size
json.type document.file.content_type
json.signers document.signers.each do |signer|
  json.extract! signer, :id, :name, :email, :role, :status
end
if document.reviewer
  json.reviewer do
    json.id document.reviewer.id
    json.name document.reviewer.user.name
    json.email document.reviewer.user.email
    json.status document.reviewer.status
  end
end

