class AddLegacyIdToTaxonConcept < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :legacy_id, :integer
  end
end
