class AddTimestampsToApiDocumentsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS documents_view"
    execute "DROP MATERIALIZED VIEW IF EXISTS api_documents_mview"
    execute "DROP VIEW IF EXISTS api_documents_view"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20151221144352', 'api_documents_view')}"
    execute "CREATE MATERIALIZED VIEW api_documents_mview AS SELECT * FROM api_documents_view"
  end

  def down
    execute "CREATE VIEW documents_view AS #{view_sql('20150817204542', 'documents_view')}"
    execute "DROP MATERIALIZED VIEW IF EXISTS api_documents_mview"
    execute "DROP VIEW IF EXISTS api_documents_view"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20151201095234', 'api_documents_view')}"
    execute "CREATE MATERIALIZED VIEW api_documents_mview AS SELECT * FROM api_documents_view"
  end
end
