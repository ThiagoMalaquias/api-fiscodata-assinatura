class AddContactInfoToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :email, :string
    add_column :companies, :phone, :string
    add_column :companies, :address, :string
    add_column :companies, :number, :string
    add_column :companies, :neighborhood, :string
    add_column :companies, :city, :string
    add_column :companies, :state, :string
    add_column :companies, :zip_code, :string
  end
end
