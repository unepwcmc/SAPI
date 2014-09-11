class CreateDocumentTagsDocuments < ActiveRecord::Migration
  def change
    create_table :document_tags_documents, :id => false do |t|
      t.references :document
      t.references :document_tag
    end

    add_index :document_tags_documents, [:document_id, :document_tag_id],
      name: 'index_document_tags_documents_composite'
    add_index :document_tags_documents, :document_tag_id
  end
end
