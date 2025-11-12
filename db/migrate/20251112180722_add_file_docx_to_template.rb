class AddFileDocxToTemplate < ActiveRecord::Migration[6.1]
  def change
    add_column :templates, :file_docx, :string
  end
end
