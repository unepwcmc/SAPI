class AddNumberToProposalDetails < ActiveRecord::Migration
  def up
    add_column(:proposal_details, :proposal_number, :text)
    execute "DROP VIEW IF EXISTS documents_view"
    execute "DROP VIEW IF EXISTS api_documents_view"
    remove_column(:documents, :number)
    execute "CREATE VIEW documents_view AS #{view_sql('20150817204542', 'documents_view')}"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20151201095234', 'api_documents_view')}"
  end

  def down
    add_column(:documents, :number, :integer)
    execute "DROP VIEW IF EXISTS documents_view"
    execute "DROP VIEW IF EXISTS api_documents_view"
    remove_column(:proposal_details, :proposal_number)
    execute "CREATE VIEW documents_view AS #{view_sql('20150817204542', 'documents_view')}"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20151117145544', 'api_documents_view')}"
  end
end
