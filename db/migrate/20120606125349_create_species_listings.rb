class CreateSpeciesListings < ActiveRecord::Migration
  def change
    create_table :species_listings do |t|
      t.integer :designation_id
      t.string :name

      t.timestamps
    end

    add_foreign_key "species_listings", "designations", :name => "species_listings_designation_id_fk"
  end
end
