class CreateDocumentCitations < ActiveRecord::Migration
  def change
    create_table :document_citations do |t|
      t.integer :document_id
      t.integer  :created_by_id
      t.integer  :updated_by_id
      t.timestamps
    end
    add_foreign_key :document_citations, :documents, name: :document_citations_document_id_fk,
      column: :document_id
    add_foreign_key :document_citations, :users, name: :document_citations_created_by_id_fk,
      column: :created_by_id
    add_foreign_key :document_citations, :users, name: :document_citations_updated_by_id_fk,
      column: :updated_by_id
  end
end
