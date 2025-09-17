class AddSignatureToSigner < ActiveRecord::Migration[6.1]
  def change
    add_column :signers, :signature, :text
  end
end
