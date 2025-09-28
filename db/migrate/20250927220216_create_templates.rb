class CreateTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :templates do |t|
      t.bigint :user_id, null: false
      t.string :title
      t.text :description
      t.text :content
      t.text :variables, array: true, default: []

      t.timestamps
    end
  end
end
