class AddAbbreviationToSpeciesListings < ActiveRecord::Migration
  def change
    add_column :species_listings, :abbreviation, :string
  end
end
