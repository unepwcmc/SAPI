class AddSubtypeAndVolumeToApiDocumentsView < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS api_documents_mview"
    execute "DROP VIEW IF EXISTS api_documents_view"

    execute "CREATE VIEW api_documents_view AS #{view_sql('20200225152373', 'api_documents_view')}"
    execute "CREATE MATERIALIZED VIEW api_documents_mview AS SELECT * FROM api_documents_view"

    add_index :api_documents_mview, [:event_id],
      name: 'index_documents_mview_on_event_id'
    add_index :api_documents_mview, [:date_raw],
      name: 'index_documents_mview_on_date_raw'
    execute <<-SQL
      CREATE INDEX index_documents_mview_on_title_to_ts_vector
      ON api_documents_mview
      USING gin
      (to_tsvector('simple'::regconfig, COALESCE(title, ''::text)));
    SQL

  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS api_documents_mview"
    execute "DROP VIEW IF EXISTS api_documents_view"

    execute "CREATE VIEW api_documents_view AS #{view_sql('20161123103614', 'api_documents_view')}"
    execute "CREATE MATERIALIZED VIEW api_documents_mview AS SELECT * FROM api_documents_view"

    add_index :api_documents_mview, [:event_id],
      name: 'index_documents_mview_on_event_id'
    add_index :api_documents_mview, [:date_raw],
      name: 'index_documents_mview_on_date_raw'
    execute <<-SQL
      CREATE INDEX index_documents_mview_on_title_to_ts_vector
      ON api_documents_mview
      USING gin
      (to_tsvector('simple'::regconfig, COALESCE(title, ''::text)));
    SQL
  end
end
