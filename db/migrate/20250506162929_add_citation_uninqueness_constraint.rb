
###
# Due to a bug, there are lots of "references" records which have been entered
# multiple times with the same citation. This patch intends to make
# "references"."citation" a unique field, and to remove all duplicates.
#
# Foreign keys to duplicates also need to be reassigned to the 'original'
# record, assumed to be the one with the smallest id. By direct observation,
# it was established that where content columns other than citation differed,
# the record with the smallest id value was the most complete.
class AddCitationUninquenessConstraint < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      reversible do |dir|
        dir.up do
          # We want to write to STDOUT here
          # rubocop:disable Rails/Output
          puts(deduplicate_references)
          # rubocop:enable Rails/Output
        end
      end

      add_index(
        :references,
        # In case citation is very long, it won't fit into an index
        # Therefore take the 32-char md5sum and add the first (1024-32) chars
        # of the citation,
        '(md5(citation) || left(citation, 992))',
        name: :index_references_on_citation_checksum,
        unique: true
      )
    end
  end

private

  def deduplicate_references
    Reference.connection.query(
      <<-SQL.squish
        WITH deduplicated_references AS (
          SELECT
            min(id) AS id,
            array_agg(id) AS all_ids
          FROM "references" r
          GROUP BY citation
          HAVING COUNT(DISTINCT(id)) > 1
        ), deduplicated_distribution_references AS (
          SELECT
            min(dr.id) AS id,
            array_agg(dr.id) AS all_ids,
            ur.id AS reference_id,
            array_agg(dr.reference_id) AS all_reference_id,
            min(dr.created_at) AS created_at,
            max(dr.updated_at) AS updated_at,
            array_agg(dr.created_by_id ORDER BY created_at) AS created_by_ids,
            array_agg(dr.updated_by_id ORDER BY updated_at DESC) AS updated_by_ids
          FROM distribution_references dr
          JOIN deduplicated_references ur
            ON dr.reference_id = ANY(ur.all_ids)
          GROUP BY dr.distribution_id, ur.id
        ), deleted_distribution_references AS (
          DELETE FROM distribution_references dr
          USING deduplicated_distribution_references udr
          WHERE dr.id = ANY(udr.all_ids)
            AND dr.id != udr.id
          RETURNING dr.*
        ), updated_distribution_references AS (
          UPDATE distribution_references dr
          SET
            reference_id = udr.reference_id,
            created_at = udr.created_at,
            updated_at = udr.updated_at,
            created_by_id = udr.created_by_ids[0],
            updated_by_id = udr.updated_by_ids[0]
          FROM (
            SELECT udr.* FROM deduplicated_distribution_references udr
            /* Force the deletion to happen first, to avoid collisions */
            JOIN (SELECT count(*) FROM deleted_distribution_references) c ON TRUE
          ) udr
          WHERE dr.id = udr.id
          RETURNING dr.*
        ), deduplicated_taxon_concept_references AS (
          SELECT
            min(tcr.id) AS id,
            array_agg(tcr.id) AS all_ids,
            ur.id AS reference_id,
            array_agg(tcr.reference_id) AS all_reference_id,
            min(tcr.created_at) AS created_at,
            max(tcr.updated_at) AS updated_at,
            array_agg(tcr.created_by_id ORDER BY created_at) AS created_by_ids,
            array_agg(tcr.updated_by_id ORDER BY updated_at DESC) AS updated_by_ids
          FROM taxon_concept_references tcr
          JOIN deduplicated_references ur
            ON tcr.reference_id = ANY(ur.all_ids)
          GROUP BY tcr.taxon_concept_id, ur.id
        ), deleted_taxon_concept_references AS (
          DELETE FROM taxon_concept_references tcr
          USING deduplicated_taxon_concept_references utcr
          WHERE tcr.id = ANY(utcr.all_ids)
            AND tcr.id != utcr.id
          RETURNING tcr.*
        ), updated_taxon_concept_references AS (
          UPDATE taxon_concept_references tcr
          SET
            reference_id = utcr.reference_id,
            created_at = utcr.created_at,
            updated_at = utcr.updated_at,
            created_by_id = utcr.created_by_ids[0],
            updated_by_id = utcr.updated_by_ids[0]
          FROM (
            SELECT utcr.* FROM deduplicated_taxon_concept_references utcr
            /* Force the deletion to happen first, to avoid collisions */
            JOIN (SELECT count(*) FROM deleted_taxon_concept_references) tcr_del ON TRUE
          ) utcr
          WHERE tcr.id = utcr.id
          RETURNING tcr.*
        ), deleted_references AS (
          DELETE FROM "references" r
          USING (
            SELECT ur.* FROM deduplicated_references ur
            /* Force the deletion to happen first, to avoid collisions */
            JOIN (SELECT count(*) FROM deleted_distribution_references) dr_del ON TRUE
            JOIN (SELECT count(*) FROM updated_distribution_references) dr_upd ON TRUE
            JOIN (SELECT count(*) FROM deleted_taxon_concept_references) tcr_del ON TRUE
            JOIN (SELECT count(*) FROM updated_taxon_concept_references) tcr_upd ON TRUE
          ) ur
          WHERE r.id = ANY(ur.all_ids)
            AND ur.id != r.id
          RETURNING r.id
        )
        SELECT row_to_json(r.*) AS deduplication_results
        FROM (
          SELECT
          (SELECT COUNT(*) FROM deduplicated_references) AS deduplicated_references,
          (SELECT COUNT(*) FROM deduplicated_distribution_references) AS deduplicated_distribution_references,
          (SELECT COUNT(*) FROM deleted_distribution_references) AS deleted_distribution_references,
          (SELECT COUNT(*) FROM updated_distribution_references) AS updated_distribution_references,
          (SELECT COUNT(*) FROM deleted_taxon_concept_references) AS deleted_taxon_concept_references,
          (SELECT COUNT(*) FROM updated_taxon_concept_references) AS updated_taxon_concept_references,
          (SELECT COUNT(*) FROM deleted_references) AS deleted_references
        ) r;
      SQL
    )
  end
end
