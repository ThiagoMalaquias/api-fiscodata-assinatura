json.array!(@documents) do |document|
  json.extract! document, :id, :name, :status, :created_at
  json.signers document.signers.size
end