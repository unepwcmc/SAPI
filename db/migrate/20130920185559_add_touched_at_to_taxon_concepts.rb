class AddTouchedAtToTaxonConcepts < ActiveRecord::Migration
  def change
  	add_column :taxon_concepts, :touched_at, :datetime
  end
end
