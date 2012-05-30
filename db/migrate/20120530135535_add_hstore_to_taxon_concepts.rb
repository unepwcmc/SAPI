class AddHstoreToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :data, :hstore
  end
end
