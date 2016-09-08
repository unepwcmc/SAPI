class CreateUniqueIndexOnTaxonConceptReferences < ActiveRecord::Migration
  def up
    sql = <<-SQL
  WITH duplicated_taxon_concept_references AS (
    SELECT primary_id, cnt, UNNEST(ids) AS id FROM (
      SELECT MIN(id) AS primary_id, COUNT(*) AS cnt, ARRAY_AGG_NOTNULL(id) AS ids
      FROM taxon_concept_references
      GROUP BY taxon_concept_id, reference_id
      HAVING COUNT(*) > 1
    ) s
  ), duplicates_to_delete AS (
    SELECT tcr.* FROM taxon_concept_references tcr
    JOIN duplicated_taxon_concept_references d
    ON tcr.id = d.id
    WHERE primary_id != d.id
  )
  DELETE FROM taxon_concept_references
  USING duplicates_to_delete
  WHERE taxon_concept_references.id = duplicates_to_delete.id
  SQL
    # remove duplicates
    execute sql

    remove_index "taxon_concept_references",
      name: "index_taxon_concept_references_on_taxon_concept_id_and_ref_id"

    add_index "taxon_concept_references", ["taxon_concept_id", "reference_id"],
      name: "index_taxon_concept_references_on_taxon_concept_id_and_ref_id",
      unique: true
  end

  def down
    remove_index "taxon_concept_references",
      name: "index_taxon_concept_references_on_taxon_concept_id_and_ref_id"

    add_index "taxon_concept_references", ["taxon_concept_id", "reference_id"],
      name: "index_taxon_concept_references_on_taxon_concept_id_and_ref_id"
  end
end
