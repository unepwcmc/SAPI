class AddUniquenessConstraints < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      reversible do |dir|
        dir.up do
          # We want to write to STDOUT here
          # rubocop:disable Rails/Output
          puts(deduplicate_distributions)
          puts(deduplicate_common_names)
          puts(deduplicate_taxon_relationships)
          puts(deduplicated_taxon_concept_references)
          # rubocop:enable Rails/Output
        end
      end

      indexes_to_add.each do |index_creation_args|
        table_name = index_creation_args[0]
        column_names = index_creation_args[1]
        options = { unique: true }.merge(index_creation_args[2] || {})

        add_index(table_name, column_names, **options)
      end
    end
  end

private

  def indexes_to_add
    [
      # bidirectional uniqueness indexes on small tables in case one is better
      # for query performance

      # ChangeType
      [ :change_types, [ :name, :designation_id ] ],
      [ :change_types, [ :designation_id, :name ] ],
      [ :change_types, [ :display_name_en, :designation_id ] ],
      [ :change_types, [ :designation_id, :display_name_en ] ],

      # Designation
      [ :designations, :name ],

      # EuDecisionType
      [ :eu_decision_types, :name ],

      # Instrument
      [ :instruments, [ :name, :designation_id ] ],
      [ :instruments, [ :designation_id, :name ] ],

      # Rank
      [ :ranks, :name ],
      [ :ranks, :display_name_en ],
      [ :ranks, :display_name_fr, { where: 'display_name_fr IS NOT NULL' } ],
      [ :ranks, :display_name_es, { where: 'display_name_es IS NOT NULL' } ],

      # SpeciesListing
      [ :species_listings, [ :name, :designation_id ] ],
      [ :species_listings, [ :designation_id, :name ] ],

      [ :species_listings, [ :abbreviation, :designation_id ] ],
      [ :species_listings, [ :designation_id, :abbreviation ] ],

      # TradeCode
      [ :trade_codes, [ :code, :type ] ],

      # Taxonomy
      [ :taxonomies, :name ],

      # CommonNames
      [ :common_names, [ :language_id, :name ] ],

      # Distributions
      [ :distributions, [ :taxon_concept_id, :geo_entity_id ] ],

      # Event
      [ :events, :name ],

      # GeoEntity
      [ :geo_entities, :iso_code2, { where: 'iso_code2 IS NOT NULL' } ],
      [ :geo_entities, :iso_code3, { where: 'iso_code3 IS NOT NULL' } ],

      # Language
      [ :languages, :iso_code1, { where: 'iso_code1 IS NOT NULL' } ],
      [ :languages, :iso_code3 ],

      # PresetTag
      [ :preset_tags, 'name, upper(model)' ],

      # SrgHistory
      [ :srg_history, :name ],

      # Taggings
      [
        :taggings, [ :tag_id, :taggable_id, :taggable_type ],
        { comment: 'Strictly this table is managed by acts_as_taggable_on - remove this index if it becomes an issue' }
      ],

      # TaxonConcept
      # TODO: Address duplicates
      # [ :taxon_concepts, [ :taxonomy_id, :full_name, :author_year ] ],

      # TaxonConceptReference
      # Linking table gets bidirectional index
      [ :taxon_concept_references, [ :taxon_concept_id, :reference_id ] ],
      [ :taxon_concept_references, [ :reference_id, :taxon_concept_id ] ],

      # TaxonRelationship
      # Linking table gets bidirectional index
      [ :taxon_relationships, [ :taxon_concept_id, :other_taxon_concept_id, :taxon_relationship_type_id ] ],
      [ :taxon_relationships, [ :other_taxon_concept_id, :taxon_concept_id, :taxon_relationship_type_id ] ],

      # TermTradeCodesPair
      # Linking table gets bidirectional index
      [ :term_trade_codes_pairs, [ :term_id, :trade_code_id ] ],
      [ :term_trade_codes_pairs, [ :trade_code_id, :term_id ] ],

      # Trade::TaxonConceptTermPair
      # Linking table gets bidirectional index
      [ :trade_taxon_concept_term_pairs, [ :term_id, :taxon_concept_id ] ],
      [ :trade_taxon_concept_term_pairs, [ :taxon_concept_id, :term_id ] ]
    ]
  end

  def deduplicate_common_names
    CommonName.connection.query(
      <<-SQL.squish
        WITH deduplicated_names AS (
          SELECT
            min(id) AS id,
            array_agg(id) AS all_ids,
            "name",
            min(created_at) AS created_at,
            max(updated_at) AS updated_at,
            array_agg(created_by_id ORDER BY created_at) AS created_by_ids,
            array_agg(updated_by_id ORDER BY updated_at DESC) AS updated_by_ids
          FROM common_names
          GROUP BY "name", language_id
          HAVING COUNT(*) > 1
        ), deduplicated_taxon_commons AS (
          SELECT
            taxon_concept_id,
            min(tc.id) AS id,
            array_agg(tc.id) AS all_ids,
            un.id AS common_name_id,
            array_agg(tc.common_name_id) AS all_common_name_ids,
            min(tc.created_at) AS created_at,
            max(tc.updated_at) AS updated_at,
            array_agg(tc.created_by_id ORDER BY tc.created_at) AS created_by_ids,
            array_agg(tc.updated_by_id ORDER BY tc.updated_at DESC) AS updated_by_ids
          FROM taxon_commons tc
          JOIN deduplicated_names un
            ON tc.common_name_id = ANY(un.all_ids)
          GROUP BY un.id, taxon_concept_id
        ), deleted_taxon_commons AS (
          DELETE FROM taxon_commons tc
          USING deduplicated_taxon_commons utc
          WHERE tc.id = ANY(utc.all_ids)
            AND tc.id != utc.id
          RETURNING tc.id
        ), updated_taxon_commons AS (
          UPDATE taxon_commons tc
          SET
            common_name_id = utc.common_name_id,
            created_at = utc.created_at,
            updated_at = utc.updated_at,
            created_by_id = utc.created_by_ids[0],
            updated_by_id = utc.updated_by_ids[0]
          FROM deduplicated_taxon_commons utc
          WHERE tc.id = utc.id
          RETURNING tc.id
        ), deleted_names AS (
          DELETE FROM common_names n
          USING deduplicated_names un
          WHERE n.id = ANY(un.all_ids)
            AND n.id != un.id
          RETURNING n.id
        ), updated_names AS (
          UPDATE common_names n
          SET
            created_at = un.created_at,
            updated_at = un.updated_at,
            created_by_id = un.created_by_ids[0],
            updated_by_id = un.updated_by_ids[0]
          FROM deduplicated_names un
          WHERE n.id = un.id
          RETURNING n.id
        )
        SELECT row_to_json(r.*) AS deduplication_results
        FROM (
          SELECT
          (SELECT count(*) FROM deduplicated_names) AS deduplicated_names,
          (SELECT count(*) FROM deduplicated_taxon_commons) AS deduplicated_taxon_commons,
          (SELECT count(*) FROM deleted_taxon_commons) AS deleted_taxon_commons,
          (SELECT count(*) FROM updated_taxon_commons) AS updated_taxon_commons,
          (SELECT count(*) FROM deleted_names) AS deleted_names,
          (SELECT count(*) FROM updated_names) AS updated_names,
          (SELECT JSON_AGG(DISTINCT(taxon_concept_id)) FROM deduplicated_taxon_commons) AS taxon_concept_ids
        ) r;
      SQL
    )
  end

  def deduplicate_distributions
    Distribution.connection.query(
      <<-SQL.squish
        WITH deduplicated_distributions AS (
          SELECT
            min(id) AS id,
            array_agg(id) AS all_ids,
            taxon_concept_id,
            geo_entity_id,
            squish_null(
              string_agg(
                DISTINCT COALESCE(internal_notes, ''), chr(10)
              )
            ) AS internal_notes
          FROM distributions d
          GROUP BY taxon_concept_id, geo_entity_id
          HAVING COUNT(DISTINCT(id)) > 1
        ), deduplicated_distribution_references AS (
          SELECT
            min(dr.id) AS id,
            array_agg(dr.id) AS all_ids,
            ud.id AS distribution_id,
            array_agg(dr.distribution_id) AS all_distribution_ids,
            min(dr.created_at) AS created_at,
            max(dr.updated_at) AS updated_at,
            array_agg(dr.created_by_id ORDER BY created_at) AS created_by_ids,
            array_agg(dr.updated_by_id ORDER BY updated_at DESC) AS updated_by_ids
          FROM distribution_references dr
          JOIN deduplicated_distributions ud
            ON dr.distribution_id = ANY(ud.all_ids)
          GROUP BY ud.id, dr.reference_id
        ), deleted_references AS (
          DELETE FROM distribution_references dr
          USING deduplicated_distribution_references udr
          WHERE dr.id = ANY(udr.all_ids)
            AND dr.id != udr.id
          RETURNING dr.*
        ), updated_references AS (
          UPDATE distribution_references dr
          SET
            distribution_id = udr.distribution_id,
            created_at = udr.created_at,
            updated_at = udr.updated_at,
            created_by_id = udr.created_by_ids[0],
            updated_by_id = udr.updated_by_ids[0]
          FROM (
            SELECT udr.* FROM deduplicated_distribution_references udr
            /* Force the deletion to happen first, to avoid collisions */
            JOIN (SELECT count(*) FROM deleted_references) c ON TRUE
          ) udr
          WHERE dr.id = udr.id
          RETURNING dr.*
        ), deduplicated_distribution_taggings AS (
          SELECT
            min(dt.id) AS id,
            array_agg(dt.id) AS all_ids,
            ud.id AS taggable_id,
            array_agg(dt.taggable_id) AS all_distribution_ids,
            min(dt.created_at) AS created_at
          FROM taggings dt
          JOIN deduplicated_distributions ud
            ON dt.taggable_id = ANY(ud.all_ids)
            AND taggable_type = 'Distribution'
          GROUP BY ud.id, dt.tag_id
        ), updated_taggings AS (
          UPDATE taggings dt
          SET
            taggable_id = udt.id,
            created_at = udt.created_at
          FROM deduplicated_distribution_taggings udt
          WHERE dt.id = udt.id
            AND dt.taggable_type = 'Distribution'
          RETURNING dt.id
        ), deleted_taggings AS (
          DELETE FROM taggings dt
          USING deduplicated_distribution_taggings udt
          WHERE dt.id != udt.id
            AND dt.id = ANY(udt.all_ids)
            AND dt.taggable_type = 'Distribution'
          RETURNING dt.id
        ), updated_reassignments AS (
          UPDATE nomenclature_change_reassignments dr
          SET reassignable_id = ud.id
          FROM deduplicated_distributions ud
          WHERE dr.reassignable_id = ANY(ud.all_ids)
            AND dr.reassignable_id != ud.id
            AND dr.reassignable_type = 'Distribution'
            AND dr.type = 'NomenclatureChange::DistributionReassignment'
          RETURNING dr.*
        ), deleted_distributions AS (
          DELETE FROM distributions d
          USING deduplicated_distributions ud
          WHERE ud.taxon_concept_id = d.taxon_concept_id
            AND ud.geo_entity_id = d.geo_entity_id
            AND ud.id != d.id
          RETURNING d.id
        ), updated_distributions AS (
          UPDATE distributions d
          SET internal_notes = ud.internal_notes
          FROM deduplicated_distributions ud
          WHERE d.id = ud.id
          RETURNING d.id
        )
        SELECT row_to_json(r.*) AS deduplication_results
        FROM (
          SELECT
          (SELECT COUNT(*) FROM deduplicated_distributions) AS deduplicated_distributions,
          (SELECT COUNT(*) FROM deduplicated_distribution_references) AS deduplicated_distribution_references,
          (SELECT COUNT(*) FROM deleted_taggings) AS deleted_taggings,
          (SELECT COUNT(*) FROM updated_taggings) AS updated_taggings,
          (SELECT COUNT(*) FROM deleted_references) AS deleted_references,
          (SELECT COUNT(*) FROM updated_references) AS updated_references,
          (SELECT COUNT(*) FROM updated_reassignments) AS updated_reassignments,
          (SELECT COUNT(*) FROM deleted_distributions) AS deleted_distributions,
          (SELECT COUNT(*) FROM updated_distributions) AS updated_distributions,
          (SELECT JSON_AGG(DISTINCT(taxon_concept_id)) FROM deduplicated_distributions) AS taxon_concept_ids
        ) r;
      SQL
    )
  end

  def deduplicate_taxon_relationships
    TaxonRelationship.connection.query(
      <<-SQL.squish
        WITH deduplicated_taxon_relationships AS (
          SELECT
            taxon_concept_id,
            other_taxon_concept_id,
            min(id) AS id,
            array_agg(id) AS all_ids,
            min(created_at) AS created_at,
            max(updated_at) AS updated_at,
            array_agg(created_by_id ORDER BY created_at) AS created_by_ids,
            array_agg(updated_by_id ORDER BY updated_at DESC) AS updated_by_ids
          FROM taxon_relationships
          GROUP BY taxon_concept_id, other_taxon_concept_id, taxon_relationship_type_id
          HAVING COUNT(*) > 1
        ), deleted_taxon_relationships AS (
          DELETE FROM taxon_relationships tr
          USING deduplicated_taxon_relationships utr
          WHERE tr.id = ANY(utr.all_ids)
            AND tr.id != utr.id
          RETURNING tr.id
        ), updated_taxon_relationships AS (
          UPDATE taxon_relationships tr
          SET
            created_at = utr.created_at,
            updated_at = utr.updated_at,
            created_by_id = utr.created_by_ids[0],
            updated_by_id = utr.updated_by_ids[0]
          FROM (
            SELECT utr.* FROM deduplicated_taxon_relationships utr
            /* Force the deletion to happen first, to avoid collisions */
            JOIN (SELECT count(*) FROM deleted_taxon_relationships) c ON TRUE
          ) utr
          WHERE tr.id = utr.id
          RETURNING tr.id
        )
        SELECT row_to_json(r.*) AS deduplication_results
        FROM (
          SELECT
          (SELECT COUNT(*) FROM deduplicated_taxon_relationships) AS deduplicated_taxon_relationships,
          (SELECT COUNT(*) FROM deleted_taxon_relationships) AS deleted_taxon_relationships,
          (SELECT COUNT(*) FROM updated_taxon_relationships) AS updated_taxon_relationships,
          (SELECT JSON_AGG(DISTINCT(taxon_concept_id)) FROM deduplicated_taxon_relationships) AS taxon_concept_ids
        ) r;
      SQL
    )
  end

  def deduplicated_taxon_concept_references
    TaxonConceptReference.connection.query(
      <<-SQL.squish
        WITH deduplicated_taxon_concept_references AS (
          SELECT
            taxon_concept_id,
            min(id) AS id,
            array_agg(id) AS all_ids,
            bool_or(is_standard) AS is_standard,
            bool_or(is_cascaded) AS is_cascaded,
            (
              SELECT array_agg(
                DISTINCT excluded_taxon_concepts_id
                ORDER BY excluded_taxon_concepts_id
              )
              FROM (
                SELECT unnest(excluded_taxon_concepts_ids)
                  AS excluded_taxon_concepts_id
                FROM taxon_concept_references tcrx
                WHERE tcrx.taxon_concept_id = tcr.taxon_concept_id
                  AND tcrx.reference_id = tcr.reference_id
              ) xtc
            ) AS excluded_taxon_concepts_ids,
            min(created_at) AS created_at,
            max(updated_at) AS updated_at,
            array_agg(created_by_id ORDER BY created_at) AS created_by_ids,
            array_agg(updated_by_id ORDER BY updated_at DESC) AS updated_by_ids
          FROM taxon_concept_references tcr
          GROUP BY taxon_concept_id, reference_id
          HAVING COUNT(DISTINCT id) > 1
        ), deleted_taxon_concept_references AS (
          DELETE FROM taxon_concept_references tcr
          USING deduplicated_taxon_concept_references utcr
          WHERE tcr.id = ANY(utcr.all_ids)
            AND tcr.id != utcr.id
          RETURNING tcr.id
        ), updated_taxon_concept_references AS (
          UPDATE taxon_concept_references tcr
          SET
            created_at = utcr.created_at,
            updated_at = utcr.updated_at,
            created_by_id = utcr.created_by_ids[0],
            updated_by_id = utcr.updated_by_ids[0]
          FROM (
            SELECT utcr.* FROM deduplicated_taxon_concept_references utcr
            /* Force the deletion to happen first, to avoid collisions */
            JOIN (SELECT COUNT(*) FROM deleted_taxon_concept_references) c ON TRUE
          ) utcr
          WHERE tcr.id = utcr.id
          RETURNING tcr.id
        )
        SELECT row_to_json(r.*) AS deduplication_results
        FROM (
          SELECT
          (SELECT COUNT(*) FROM deduplicated_taxon_concept_references) AS deduplicated_taxon_concept_references,
          (SELECT COUNT(*) FROM deleted_taxon_concept_references) AS deleted_taxon_concept_references,
          (SELECT COUNT(*) FROM updated_taxon_concept_references) AS updated_taxon_concept_references,
          (SELECT JSON_AGG(DISTINCT(taxon_concept_id)) FROM deduplicated_taxon_concept_references) AS taxon_concept_ids
        ) r;
      SQL
    )
  end
end
