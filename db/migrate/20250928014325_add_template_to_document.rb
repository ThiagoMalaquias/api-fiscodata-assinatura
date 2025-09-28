class AddTemplateToDocument < ActiveRecord::Migration[6.1]
  def change
    add_reference :documents, :template, null: true, foreign_key: true
  end
end
