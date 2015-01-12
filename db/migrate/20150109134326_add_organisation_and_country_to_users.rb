class AddOrganisationAndCountryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :organisation, :string
    add_column :users, :geo_entity_id, :integer
  end
end
