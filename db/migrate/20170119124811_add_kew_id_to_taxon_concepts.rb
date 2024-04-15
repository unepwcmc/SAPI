class AddKewIdToTaxonConcepts < ActiveRecord::Migration[4.2]
  def change
    add_column :taxon_concepts, :kew_id, :integer
  end
end
