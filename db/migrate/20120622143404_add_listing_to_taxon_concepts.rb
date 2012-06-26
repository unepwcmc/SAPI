class AddListingToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :listing, :hstore
  end
end
