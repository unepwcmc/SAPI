class AddRawDateToApiDocumentsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS api_documents_view"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20151117145544', 'api_documents_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_documents_view"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20150820183942', 'api_documents_view')}"
  end
end
