class CreateSigners < ActiveRecord::Migration[6.1]
  def change
    create_table :signers do |t|
      t.references :document, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :role
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
