class AddVariablesToSigner < ActiveRecord::Migration[6.1]
  def change
    add_column :signers, :variables, :jsonb, default: {}
  end
end
