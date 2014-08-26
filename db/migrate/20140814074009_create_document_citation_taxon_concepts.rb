class CreateDocumentCitationTaxonConcepts < ActiveRecord::Migration
  def change
    create_table :document_citation_taxon_concepts do |t|
      t.integer :document_citation_id
      t.integer :taxon_concept_id
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
    add_foreign_key :document_citation_taxon_concepts, :document_citations, name: :document_citation_taxon_concepts_document_citation_id_fk,
      column: :document_citation_id
    add_foreign_key :document_citation_taxon_concepts, :taxon_concepts, name: :document_citation_taxon_concepts_taxon_concept_id_fk,
      column: :taxon_concept_id
    add_foreign_key :document_citation_taxon_concepts, :users, name: :document_citation_taxon_concepts_created_by_id_fk,
      column: :created_by_id
    add_foreign_key :document_citation_taxon_concepts, :users, name: :document_citation_taxon_concepts_updated_by_id_fk,
      column: :updated_by_id
  end
end
