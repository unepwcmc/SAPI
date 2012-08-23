class AddLegacyTypeToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :legacy_type, :string
  end
end
