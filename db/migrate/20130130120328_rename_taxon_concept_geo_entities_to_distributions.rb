class RenameTaxonConceptGeoEntitiesToDistributions < ActiveRecord::Migration
  def change
    rename_table :taxon_concept_geo_entities, :distributions
    rename_table :taxon_concept_geo_entity_references, :distribution_references
    rename_column :distribution_references, :taxon_concept_geo_entity_id, :distribution_id
  end
end
