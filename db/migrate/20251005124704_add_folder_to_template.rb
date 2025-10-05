class AddFolderToTemplate < ActiveRecord::Migration[6.1]
  def change
    add_reference :templates, :template_folder, null: true, foreign_key: true
  end
end
