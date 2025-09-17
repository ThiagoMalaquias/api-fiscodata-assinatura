class AddRejectedAtToSigner < ActiveRecord::Migration[6.1]
  def change
    add_column :signers, :rejected_at, :datetime
  end
end
