CREATE OR REPLACE FUNCTION rebuild_designation_listing_changes_mview(
  taxonomy taxonomies, designation designations
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    all_lc_table_name TEXT;
    lc_table_name TEXT;
    sql TEXT;
    addition_id INT;
    deletion_id INT;
  BEGIN
    PERFORM rebuild_designation_all_listing_changes_mview(taxonomy, designation);

    SELECT LOWER(designation.name) || '_all_listing_changes_mview' INTO all_lc_table_name;
    SELECT LOWER(designation.name) || '_listing_changes_mview' INTO lc_table_name;

    EXECUTE 'DROP TABLE IF EXISTS ' || lc_table_name || ' CASCADE';

    RAISE NOTICE '* creating % materialized view', lc_table_name;
    sql := 'CREATE TEMP TABLE ' || lc_table_name || ' AS
    WITH applicable_listing_changes AS (
        SELECT affected_taxon_concept_id,'
        || LOWER(designation.name) || '_applicable_listing_changes_for_node(
          affected_taxon_concept_id
        ) AS listing_change_id
        FROM ' || all_lc_table_name
        || ' GROUP BY affected_taxon_concept_id
    )
    SELECT
    applicable_listing_changes.affected_taxon_concept_id AS taxon_concept_id,
    listing_changes.id AS id,
    listing_changes.taxon_concept_id AS original_taxon_concept_id,
    effective_at,
    species_listing_id,
    species_listings.abbreviation AS species_listing_name,
    change_type_id, change_types.name AS change_type_name,
    change_types.designation_id AS designation_id,
    designations.name AS designation_name,
    listing_changes.parent_id,
    listing_distributions.geo_entity_id AS party_id,
    geo_entities.iso_code2 AS party_iso_code,
    annotations.symbol AS ann_symbol,
    annotations.full_note_en,
    annotations.full_note_es,
    annotations.full_note_fr,
    annotations.short_note_en,
    annotations.short_note_es,
    annotations.short_note_fr,
    annotations.display_in_index,
    annotations.display_in_footnote,
    hash_annotations.symbol AS hash_ann_symbol,
    hash_annotations.parent_symbol AS hash_ann_parent_symbol,
    hash_annotations.full_note_en AS hash_full_note_en,
    hash_annotations.full_note_es AS hash_full_note_es,
    hash_annotations.full_note_fr AS hash_full_note_fr,
    inclusion_taxon_concept_id,
    NULL::TEXT AS inherited_short_note_en, -- this column is populated later
    NULL::TEXT AS inherited_full_note_en, -- this column is populated later
    CASE
    WHEN inclusion_taxon_concept_id IS NOT NULL
    THEN ancestor_listing_auto_note(
      inclusion_taxon_concepts.data->''rank_name'',
      inclusion_taxon_concepts.full_name,
      change_types.name
    )
    WHEN applicable_listing_changes.affected_taxon_concept_id != listing_changes.taxon_concept_id
    THEN ancestor_listing_auto_note(
      original_taxon_concepts.data->''rank_name'',
      original_taxon_concepts.full_name,
      change_types.name
    )
    ELSE NULL
    END AS auto_note,
    listing_changes.is_current,
    listing_changes.explicit_change,
    populations.countries_ids_ary,
    CASE
    WHEN change_types.name != ''EXCEPTION'' AND listing_changes.explicit_change
    THEN TRUE
    ELSE FALSE
    END AS show_in_history,
    CASE
    WHEN change_types.name != ''EXCEPTION'' AND listing_changes.explicit_change
    THEN TRUE
    ELSE FALSE
    END AS show_in_downloads,
    CASE
    WHEN change_types.name != ''EXCEPTION''
    THEN TRUE
    ELSE FALSE
    END AS show_in_timeline
    FROM
    applicable_listing_changes
    JOIN listing_changes ON applicable_listing_changes.listing_change_id  = listing_changes.id
    JOIN taxon_concepts original_taxon_concepts
    ON original_taxon_concepts.id = listing_changes.taxon_concept_id
    LEFT JOIN taxon_concepts inclusion_taxon_concepts
    ON inclusion_taxon_concepts.id = listing_changes.inclusion_taxon_concept_id
    INNER JOIN change_types
    ON listing_changes.change_type_id = change_types.id
    INNER JOIN designations
    ON change_types.designation_id = designations.id
    LEFT JOIN species_listings
    ON listing_changes.species_listing_id = species_listings.id
    LEFT JOIN listing_distributions
    ON listing_changes.id = listing_distributions.listing_change_id
    AND listing_distributions.is_party = ''t''
    LEFT JOIN geo_entities ON
    geo_entities.id = listing_distributions.geo_entity_id
    LEFT JOIN annotations ON
    annotations.id = listing_changes.annotation_id
    LEFT JOIN annotations hash_annotations ON
    hash_annotations.id = listing_changes.hash_annotation_id
    LEFT JOIN (
    SELECT listing_change_id, ARRAY_AGG(geo_entities.id) AS countries_ids_ary
    FROM listing_distributions
    INNER JOIN geo_entities
    ON geo_entities.id = listing_distributions.geo_entity_id
    WHERE NOT is_party
    GROUP BY listing_change_id
    ) populations ON populations.listing_change_id = listing_changes.id
    ORDER BY taxon_concept_id, effective_at,
    CASE
    WHEN change_types.name = ''ADDITION'' THEN 0
    WHEN change_types.name = ''RESERVATION'' THEN 1
    WHEN change_types.name = ''RESERVATION_WITHDRAWAL'' THEN 2
    WHEN change_types.name = ''DELETION'' THEN 3
    END';

    EXECUTE sql;

    EXECUTE 'CREATE INDEX ON ' || lc_table_name || ' (id, taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || lc_table_name || ' (inclusion_taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || lc_table_name || ' (taxon_concept_id, original_taxon_concept_id, change_type_id, effective_at)';

    -- now for those taxon concepts that only have inherited legislation,
    -- ignore them in downloads
    sql := 'WITH taxon_concepts_with_inherited_legislation_only AS (
      SELECT taxon_concept_id
      FROM ' || lc_table_name
      || ' GROUP BY taxon_concept_id
      HAVING EVERY(original_taxon_concept_id != taxon_concept_id)
    )
    UPDATE '|| lc_table_name || ' listing_changes_mview
    SET show_in_downloads = FALSE
    FROM taxon_concepts_with_inherited_legislation_only
    WHERE taxon_concepts_with_inherited_legislation_only.taxon_concept_id = listing_changes_mview.taxon_concept_id';

    EXECUTE sql;

    RAISE NOTICE 'Terminating non-current inherited listings';

    SELECT id INTO deletion_id FROM change_types WHERE name = 'DELETION' AND designation_id = designation.id;
    SELECT id INTO addition_id FROM change_types WHERE name = 'ADDITION' AND designation_id = designation.id;
    -- find inherited listing changes superceded by own listing changes
    -- mark them as not current in context of the child and add fake deletion records
    -- so that those inherited events are terminated properly on the timelines
    sql := 'WITH next_lc AS (
      SELECT taxon_concept_id, original_taxon_concept_id, species_listing_id, effective_at
      FROM ' || lc_table_name
      || ' -- note to self: removed the is_current filter here to also handle cases
      -- where an appendix changed in the past, e.g. Amazona auropalliata
      WHERE change_type_id = ' || addition_id
    || '), prev_lc AS (
      SELECT id, 
      listing_changes_mview.original_taxon_concept_id, 
      listing_changes_mview.taxon_concept_id, 
      next_lc.effective_at,
      listing_changes_mview.species_listing_id, 
      species_listing_name,
      designation_id, designation_name,
      party_id, party_iso_code,
      listing_changes_mview.species_listing_id != next_lc.species_listing_id AS appendix_change
      FROM next_lc
      JOIN ' || lc_table_name || ' listing_changes_mview      
      ON listing_changes_mview.taxon_concept_id = next_lc.taxon_concept_id
      AND change_type_id = 1
      AND listing_changes_mview.effective_at < next_lc.effective_at
      AND (
        (
          -- own listing change preceded by inherited listing change
          next_lc.original_taxon_concept_id = next_lc.taxon_concept_id
          AND listing_changes_mview.original_taxon_concept_id != listing_changes_mview.taxon_concept_id
        ) OR (
          -- own listing change preceded by own listing change if it is a not current inclusion
          next_lc.original_taxon_concept_id = next_lc.taxon_concept_id
          AND listing_changes_mview.original_taxon_concept_id = listing_changes_mview.taxon_concept_id
          AND listing_changes_mview.inclusion_taxon_concept_id IS NOT NULL
          AND NOT listing_changes_mview.is_current
        ) OR (
          -- inherited listing change preceded by inherited listing change
          next_lc.original_taxon_concept_id != next_lc.taxon_concept_id
          AND listing_changes_mview.original_taxon_concept_id != listing_changes_mview.taxon_concept_id
        ) OR (
          -- inherited listing change preceded by own listing change if it is a not current inclusion
          -- in the same taxon concept as the current listing change
          next_lc.original_taxon_concept_id != next_lc.taxon_concept_id
          AND listing_changes_mview.original_taxon_concept_id = listing_changes_mview.taxon_concept_id
          AND listing_changes_mview.inclusion_taxon_concept_id IS NOT NULL
          AND (
            listing_changes_mview.inclusion_taxon_concept_id = next_lc.original_taxon_concept_id
            OR NOT listing_changes_mview.is_current
          )
        )
      )
    ), fake_deletions AS (
      -- note: this inserts records without an id
      -- this is ok for the timelines, and those records are not used elsewhere
      -- note to self: ids in this view are not unique anyway, since any id
      -- from listing changes can occur multiple times
      INSERT INTO ' || lc_table_name || ' (
        original_taxon_concept_id, taxon_concept_id,
        effective_at,
        species_listing_id, species_listing_name,
        change_type_id, change_type_name,
        designation_id, designation_name,
        party_id, party_iso_code,
        is_current, explicit_change,
        show_in_timeline, show_in_downloads, show_in_history
      )
      SELECT 
      original_taxon_concept_id, taxon_concept_id,
      MIN(effective_at) AS effective_at, 
      species_listing_id, species_listing_name, '
      || deletion_id ||', ''DELETION'', 
      prev_lc.designation_id, designation_name, 
      party_id, party_iso_code, 
      TRUE AS is_current, FALSE AS explicit_change,
      TRUE AS show_in_timeline, FALSE AS show_in_downloads, FALSE AS show_in_history
      FROM prev_lc
      WHERE appendix_change
      GROUP BY original_taxon_concept_id, taxon_concept_id, 
      species_listing_id, species_listing_name,
      prev_lc.designation_id, designation_name, party_id, party_iso_code
      RETURNING *
    )
    UPDATE ' || lc_table_name || ' SET is_current = FALSE
    FROM prev_lc terminated_lc
    WHERE terminated_lc.id = ' || lc_table_name || '.id 
    AND terminated_lc.taxon_concept_id = ' || lc_table_name || '.taxon_concept_id';

    EXECUTE sql;

    RAISE NOTICE '* % merging inclusion records with their ancestor counterparts', lc_table_name;

    sql := 'WITH double_inclusions AS (
      SELECT lc.taxon_concept_id, lc.id AS own_inclusion_id, lc_inh.id AS inherited_inclusion_id, 
      lc_inh.full_note_en AS inherited_full_note_en,
      lc_inh.short_note_en AS inherited_short_note_en
      FROM ' || lc_table_name || ' lc
      JOIN ' || lc_table_name || ' lc_inh
      ON lc.taxon_concept_id = lc_inh.taxon_concept_id
      AND lc.species_listing_id = lc_inh.species_listing_id
      AND lc.change_type_id = lc_inh.change_type_id
      AND lc.effective_at = lc_inh.effective_at
      AND (lc.party_id IS NULL OR lc.party_id = lc_inh.party_id)
      AND lc.inclusion_taxon_concept_id = lc_inh.original_taxon_concept_id
      WHERE lc.inclusion_taxon_concept_id IS NOT NULL
    ), rows_to_be_deleted AS (
      DELETE
      FROM ' || lc_table_name || ' lc
      USING double_inclusions
      WHERE double_inclusions.taxon_concept_id = lc.taxon_concept_id
      AND double_inclusions.inherited_inclusion_id = lc.id
      RETURNING *
    )
    UPDATE ' || lc_table_name || ' lc
    SET inherited_full_note_en = double_inclusions.inherited_full_note_en,
    inherited_short_note_en = double_inclusions.inherited_short_note_en
    FROM double_inclusions
    WHERE double_inclusions.taxon_concept_id = lc.taxon_concept_id
    AND double_inclusions.own_inclusion_id = lc.id
    AND (double_inclusions.inherited_full_note_en IS NOT NULL OR double_inclusions.inherited_short_note_en IS NOT NULL)';

    EXECUTE sql;
  END;
  $$;

COMMENT ON FUNCTION rebuild_designation_listing_changes_mview(designation designations) IS 
'Procedure to rebuild designation listing changes materialized view in the database.';
