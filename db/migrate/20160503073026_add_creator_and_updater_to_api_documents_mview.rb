class AddCreatorAndUpdaterToApiDocumentsMview < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS api_documents_mview"
    execute "DROP VIEW IF EXISTS api_documents_view"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20160503073026', 'api_documents_view')}"
    execute "CREATE MATERIALIZED VIEW api_documents_mview AS SELECT * FROM api_documents_view"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS api_documents_mview"
    execute "DROP VIEW IF EXISTS api_documents_view"
    execute "CREATE VIEW api_documents_view AS #{view_sql('20160223104016', 'api_documents_view')}"
    execute "CREATE MATERIALIZED VIEW api_documents_mview AS SELECT * FROM api_documents_view"
  end
end
