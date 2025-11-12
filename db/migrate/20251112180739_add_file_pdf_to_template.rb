class AddFilePdfToTemplate < ActiveRecord::Migration[6.1]
  def change
    add_column :templates, :file_pdf, :string
  end
end
