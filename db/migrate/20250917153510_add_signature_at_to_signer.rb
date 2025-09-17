class AddSignatureAtToSigner < ActiveRecord::Migration[6.1]
  def change
    add_column :signers, :signature_at, :datetime
  end
end
