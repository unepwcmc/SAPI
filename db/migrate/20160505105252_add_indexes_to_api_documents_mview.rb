class AddIndexesToApiDocumentsMview < ActiveRecord::Migration
  def up
    add_index :api_documents_mview, [:event_id],
      name: 'index_documents_mview_on_event_id'
    add_index :api_documents_mview, [:date_raw],
      name: 'index_documents_mview_on_date_raw'
    execute <<-SQL
      CREATE INDEX index_documents_mview_on_taxon_concepts_ids
      ON api_documents_mview
      USING GIN (taxon_concept_ids)
    SQL
    execute <<-SQL
      CREATE INDEX index_documents_mview_on_geo_entity_ids
      ON api_documents_mview
      USING GIN (geo_entity_ids)
    SQL
    execute <<-SQL
      CREATE INDEX index_documents_mview_on_title_to_ts_vector
      ON api_documents_mview
      USING gin
      (to_tsvector('simple'::regconfig, COALESCE(title, ''::text)));
    SQL
  end

  def down
    remove_index :api_documents_mview, name: 'index_documents_mview_on_event_id'
    remove_index :api_documents_mview, name: 'index_documents_mview_on_date_raw'
    remove_index :api_documents_mview, name: 'index_documents_mview_on_taxon_concepts_ids'
    remove_index :api_documents_mview, name: 'index_documents_mview_on_geo_entity_ids'
    remove_index :api_documents_mview, name: 'index_documents_mview_on_title_to_ts_vector'
  end
end
