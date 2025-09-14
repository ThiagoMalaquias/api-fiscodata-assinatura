class AddCodeToSigners < ActiveRecord::Migration[6.1]
  def change
    add_column :signers, :code, :string
  end
end
