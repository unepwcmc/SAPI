class AddEventIdToApiDocumentsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS api_documents_view"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20150818131407', 'api_documents_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_documents_view"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20150817102427', 'api_documents_view')}"
  end
end
