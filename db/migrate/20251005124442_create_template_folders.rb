class CreateTemplateFolders < ActiveRecord::Migration[6.1]
  def change
    create_table :template_folders do |t|
      t.references :user, null: true, foreign_key: true
      t.references :origin, polymorphic: true, null: true
      t.string :name

      t.timestamps
    end
  end
end
