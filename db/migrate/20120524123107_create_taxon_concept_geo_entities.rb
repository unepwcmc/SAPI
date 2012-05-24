class CreateTaxonConceptGeoEntities < ActiveRecord::Migration
  def change
    create_table :taxon_concept_geo_entities do |t|
      t.integer :taxon_concept_id, :null => false
      t.integer :geo_entity_id, :null => false

      t.timestamps
    end
    add_foreign_key "taxon_concept_geo_entities", "taxon_concepts", :column => "taxon_concept_id"
    add_foreign_key "taxon_concept_geo_entities", "geo_entities", :column => "geo_entity_id"
  end
end
