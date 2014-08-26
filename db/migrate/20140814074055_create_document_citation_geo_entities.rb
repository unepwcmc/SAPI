class CreateDocumentCitationGeoEntities < ActiveRecord::Migration
  def change
    create_table :document_citation_geo_entities do |t|
      t.integer :document_citation_id
      t.integer :geo_entity_id
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
    add_foreign_key :document_citation_geo_entities, :document_citations, name: :document_citation_geo_entities_document_citation_id_fk,
      column: :document_citation_id
    add_foreign_key :document_citation_geo_entities, :geo_entities, name: :document_citation_geo_entities_geo_entity_id_fk,
      column: :geo_entity_id
    add_foreign_key :document_citation_geo_entities, :users, name: :document_citation_geo_entities_created_by_id_fk,
      column: :created_by_id
    add_foreign_key :document_citation_geo_entities, :users, name: :document_citation_geo_entities_updated_by_id_fk,
      column: :updated_by_id
  end
end
