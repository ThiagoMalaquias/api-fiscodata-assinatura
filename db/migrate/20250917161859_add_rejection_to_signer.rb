class AddRejectionToSigner < ActiveRecord::Migration[6.1]
  def change
    add_column :signers, :rejection, :text
  end
end
