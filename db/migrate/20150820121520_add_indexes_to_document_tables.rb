class AddIndexesToDocumentTables < ActiveRecord::Migration
  def change
    sql = <<-SQL
  WITH duplicated_document_citation_taxon_concepts AS (
    SELECT primary_id, cnt, UNNEST(ids) AS id FROM (
      SELECT MIN(id) AS primary_id, COUNT(*) AS cnt, ARRAY_AGG_NOTNULL(id) AS ids
      FROM document_citation_taxon_concepts
      GROUP BY taxon_concept_id, document_citation_id
      HAVING COUNT(*) > 1
    ) s
  ), duplicates_to_delete AS (
    SELECT dctc.* FROM document_citation_taxon_concepts dctc
    JOIN duplicated_document_citation_taxon_concepts d
    ON dctc.id = d.id
    WHERE primary_id != d.id
  )
  DELETE FROM document_citation_taxon_concepts
  USING duplicates_to_delete
  WHERE document_citation_taxon_concepts.id = duplicates_to_delete.id
  SQL
    # remove duplicates
    execute sql
    add_index "document_citation_taxon_concepts", ["taxon_concept_id", "document_citation_id"],
      name: "index_citation_taxon_concepts_on_taxon_concept_id_citation_id",
      unique: true
    sql = <<-SQL
  WITH duplicated_document_citation_geo_entities AS (
    SELECT primary_id, cnt, UNNEST(ids) AS id FROM (
      SELECT MIN(id) AS primary_id, COUNT(*) AS cnt, ARRAY_AGG_NOTNULL(id) AS ids
      FROM document_citation_geo_entities
      GROUP BY geo_entity_id, document_citation_id
      HAVING COUNT(*) > 1
    ) s
  ), duplicates_to_delete AS (
    SELECT dctc.* FROM document_citation_geo_entities dctc
    JOIN duplicated_document_citation_geo_entities d
    ON dctc.id = d.id
    WHERE primary_id != d.id
  )
  DELETE FROM document_citation_geo_entities
  USING duplicates_to_delete
  WHERE document_citation_geo_entities.id = duplicates_to_delete.id
  SQL
    # remove duplicates
    execute sql
    add_index "document_citation_geo_entities", ["geo_entity_id", "document_citation_id"],
      name: "index_citation_geo_entities_on_geo_entity_id_citation_id",
      unique: true
    add_index "document_citations", "document_id"
    add_index "proposal_details", "proposal_outcome_id"
    add_index "review_details", "review_phase_id"
    add_index "review_details", "process_stage_id"
    add_index "documents", ["language_id", "primary_language_document_id"],
      unique: true
    add_index "documents", "event_id"
  end
end
