class CreateApiDocumentsMview < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS api_documents_mview"
    execute "CREATE MATERIALIZED VIEW api_documents_mview AS SELECT * FROM api_documents_view"
    execute "CREATE INDEX ON api_documents_mview(event_id)"
    execute "CREATE INDEX ON api_documents_mview (date_raw)"
    execute "CREATE INDEX ON api_documents_mview USING GIN (taxon_concept_ids)"
    execute "CREATE INDEX ON api_documents_mview USING GIN (geo_entity_ids)"
    execute <<-SQL
      CREATE INDEX index_mdocuments_on_title_to_ts_vector
      ON api_documents_mview
      USING gin
      (to_tsvector('simple'::regconfig, COALESCE(title, ''::text)));
    SQL
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS api_documents_mview"
  end
end
