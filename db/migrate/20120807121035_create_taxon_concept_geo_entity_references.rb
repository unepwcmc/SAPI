class CreateTaxonConceptGeoEntityReferences < ActiveRecord::Migration
  def change
    create_table :taxon_concept_geo_entity_references do |t|
      t.integer :taxon_concept_geo_entity_id
      t.integer :reference_id
    end
    add_foreign_key :taxon_concept_geo_entity_references, :taxon_concept_geo_entities, :name => :taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk
    add_foreign_key :taxon_concept_geo_entity_references, :references, :name => :taxon_concept_geo_entity_references_reference_id_fk
  end
end
