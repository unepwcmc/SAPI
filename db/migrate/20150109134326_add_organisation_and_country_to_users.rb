class AddOrganisationAndCountryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :organisation, :string
    add_column :users, :country, :integer
  end
end
