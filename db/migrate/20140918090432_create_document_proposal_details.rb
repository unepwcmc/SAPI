class CreateDocumentProposalDetails < ActiveRecord::Migration
  def change
    create_table :proposal_details do |t|
      t.integer :document_id
      t.text :proposal_nature
      t.integer :proposal_outcome_id
      t.text :representation

      t.timestamps
    end

    add_foreign_key :proposal_details, :documents, name: :proposal_details_document_id_fk,
      column: :document_id
    add_foreign_key :proposal_details, :document_tags, name: :proposal_details_proposal_outcome_id_fk,
      column: :proposal_outcome_id
  end
end
