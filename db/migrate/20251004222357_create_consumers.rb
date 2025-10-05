class CreateConsumers < ActiveRecord::Migration[6.1]
  def change
    create_table :consumers do |t|
      t.belongs_to :company, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.string :cpf
      t.string :cnpj

      t.timestamps
    end
  end
end
