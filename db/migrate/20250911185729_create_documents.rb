class CreateDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :documents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :file
      t.text :description
      t.string :status, default: "pending"
      t.date :deadline_at

      t.timestamps
    end
  end
end
