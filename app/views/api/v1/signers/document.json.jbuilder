json.extract! @signer.document, :id, :name, :description, :deadline_at

json.file rails_blob_url(@signer.document.file)
json.signer do
  json.extract! @signer, :name, :email, :role
end
json.status @signer.status
json.signature rails_blob_url(@signer.signature) if @signer.signature.attached?