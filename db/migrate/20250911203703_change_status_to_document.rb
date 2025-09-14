class ChangeStatusToDocument < ActiveRecord::Migration[6.1]
  def change
    change_column :documents, :status, :string, default: "pending"
  end
end
