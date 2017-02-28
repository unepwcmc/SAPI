class AddKewIdToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :kew_id, :integer
  end
end
