class FilterTaxonConceptsByNameStatusInDocumentsView < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS document_citations_mview CASCADE"
    execute "DROP VIEW IF EXISTS document_citations_view"

    execute "DROP MATERIALIZED VIEW IF EXISTS api_documents_mview"
    execute "DROP VIEW IF EXISTS api_documents_view"

    execute "CREATE VIEW document_citations_view AS #{view_sql('20161123103614', 'document_citations_view')}"
    execute "CREATE MATERIALIZED VIEW document_citations_mview AS SELECT * FROM document_citations_view"

    add_index :document_citations_mview,
      [:document_id, :taxon_concept_id, :geo_entity_id, :id],
      name: :index_combinations_mview_on_document_id_tc_id_ge_id,
      unique: true

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

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS document_citations_mview CASCADE"
    execute "DROP VIEW IF EXISTS document_citations_view"

    execute "DROP MATERIALIZED VIEW IF EXISTS api_documents_mview"
    execute "DROP VIEW IF EXISTS api_documents_view"

    execute "CREATE VIEW document_citations_view AS #{view_sql('20160623105336', 'document_citations_view')}"
    execute "CREATE MATERIALIZED VIEW document_citations_mview AS SELECT * FROM document_citations_view"

    add_index :document_citations_mview,
      [:document_id, :taxon_concept_id, :geo_entity_id, :id],
      name: :index_combinations_mview_on_document_id_tc_id_ge_id,
      unique: true

    execute "CREATE VIEW api_documents_view AS #{view_sql('20160623105336', 'api_documents_view')}"
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
