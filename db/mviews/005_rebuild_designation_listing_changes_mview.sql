DROP FUNCTION IF EXISTS rebuild_designation_listing_changes_mview(
  taxonomy taxonomies, designation designations
);
CREATE OR REPLACE FUNCTION rebuild_designation_listing_changes_mview(
  taxonomy taxonomies, designation designations, events_ids INT[]
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    all_lc_table_name TEXT;
    tmp_lc_table_name TEXT;
    raw_lc_table_name TEXT;
    lc_table_name TEXT;
    master_lc_table_name TEXT;
    sql TEXT;
    addition_id INT;
    deletion_id INT;
  BEGIN
    SELECT listing_changes_mview_name('all', designation.name, events_ids)
    INTO all_lc_table_name;
    SELECT listing_changes_mview_name('tmp', designation.name, events_ids)
    INTO raw_lc_table_name;
    SELECT listing_changes_mview_name('tmp_cascaded', designation.name, events_ids)
    INTO tmp_lc_table_name;
    SELECT listing_changes_mview_name('child', designation.name, events_ids)
    INTO lc_table_name;
    SELECT listing_changes_mview_name(NULL, designation.name, events_ids)
    INTO master_lc_table_name;


    RAISE INFO 'Creating %', tmp_lc_table_name;
    EXECUTE 'DROP TABLE IF EXISTS ' || tmp_lc_table_name || ' CASCADE';

    sql := 'CREATE TABLE ' || tmp_lc_table_name || ' AS
    WITH applicable_listing_changes AS (
        SELECT affected_taxon_concept_id,'
        || designation.name || '_applicable_listing_changes_for_node(''' ||
          all_lc_table_name || ''', affected_taxon_concept_id
        ) AS listing_change_id
        FROM ' || all_lc_table_name
        || ' GROUP BY affected_taxon_concept_id
    )
    SELECT
    applicable_listing_changes.affected_taxon_concept_id AS taxon_concept_id,
    listing_changes.id AS id,
    listing_changes.taxon_concept_id AS original_taxon_concept_id,
    listing_changes.event_id,
    listing_changes.effective_at,
    listing_changes.species_listing_id,
    species_listings.abbreviation AS species_listing_name,
    listing_changes.change_type_id,
    change_types.name AS change_type_name,
    change_types.designation_id AS designation_id,
    designations.name AS designation_name,
    listing_changes.parent_id,
    listing_changes.nomenclature_note_en,
    listing_changes.nomenclature_note_fr,
    listing_changes.nomenclature_note_es,
    tmp_lc.party_id,
    geo_entities.iso_code2 AS party_iso_code,
    geo_entities.name_en AS party_full_name_en,
    geo_entities.name_es AS party_full_name_es,
    geo_entities.name_fr AS party_full_name_fr,
    geo_entity_types.name AS geo_entity_type,
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
    listing_changes.inclusion_taxon_concept_id,
    NULL::TEXT AS inherited_short_note_en, -- this column is populated later
    NULL::TEXT AS inherited_full_note_en, -- this column is populated later
    NULL::TEXT AS inherited_short_note_es, -- this column is populated later
    NULL::TEXT AS inherited_full_note_es, -- this column is populated later
    NULL::TEXT AS inherited_short_note_fr, -- this column is populated later
    NULL::TEXT AS inherited_full_note_fr, -- this column is populated later
    CASE
    WHEN listing_changes.inclusion_taxon_concept_id IS NOT NULL
    THEN ancestor_listing_auto_note_en(
      inclusion_taxon_concepts, listing_changes
    )
    WHEN applicable_listing_changes.affected_taxon_concept_id != listing_changes.taxon_concept_id
    THEN ancestor_listing_auto_note_en(
      original_taxon_concepts, listing_changes
    )
    ELSE NULL
    END AS auto_note_en,
    CASE
    WHEN listing_changes.inclusion_taxon_concept_id IS NOT NULL
    THEN ancestor_listing_auto_note_es(
      inclusion_taxon_concepts, listing_changes
    )
    WHEN applicable_listing_changes.affected_taxon_concept_id != listing_changes.taxon_concept_id
    THEN ancestor_listing_auto_note_es(
      original_taxon_concepts, listing_changes
    )
    ELSE NULL
    END AS auto_note_es,
    CASE
    WHEN listing_changes.inclusion_taxon_concept_id IS NOT NULL
    THEN ancestor_listing_auto_note_fr(
      inclusion_taxon_concepts, listing_changes
    )
    WHEN applicable_listing_changes.affected_taxon_concept_id != listing_changes.taxon_concept_id
    THEN ancestor_listing_auto_note_fr(
      original_taxon_concepts, listing_changes
    )
    ELSE NULL
    END AS auto_note_fr,
    listing_changes.is_current,
    listing_changes.explicit_change,
    --populations.countries_ids_ary,
    listing_changes.updated_at,
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
    END AS show_in_timeline,
    tmp_lc.listed_geo_entities_ids,
    tmp_lc.excluded_geo_entities_ids,
    tmp_lc.excluded_taxon_concept_ids,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM
    applicable_listing_changes
    JOIN listing_changes ON applicable_listing_changes.listing_change_id  = listing_changes.id
    JOIN ' || raw_lc_table_name || ' tmp_lc
    ON applicable_listing_changes.listing_change_id  = tmp_lc.id
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
    LEFT JOIN geo_entities ON
    geo_entities.id = tmp_lc.party_id
    LEFT JOIN geo_entity_types ON
    geo_entity_types.id = geo_entities.geo_entity_type_id
    LEFT JOIN annotations ON
    annotations.id = listing_changes.annotation_id
    LEFT JOIN annotations hash_annotations ON
    hash_annotations.id = listing_changes.hash_annotation_id
    ORDER BY taxon_concept_id, listing_changes.effective_at,
    CASE
    WHEN change_types.name = ''ADDITION'' THEN 0
    WHEN change_types.name = ''RESERVATION'' THEN 1
    WHEN change_types.name = ''RESERVATION_WITHDRAWAL'' THEN 2
    WHEN change_types.name = ''DELETION'' THEN 3
    END';

    EXECUTE sql;

    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (id, taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (inclusion_taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (taxon_concept_id, original_taxon_concept_id, change_type_id, effective_at)';

    -- now for those taxon concepts that only have inherited legislation,
    -- ignore them in downloads
    sql := 'WITH taxon_concepts_with_inherited_legislation_only AS (
      SELECT taxon_concept_id
      FROM ' || tmp_lc_table_name
      || ' GROUP BY taxon_concept_id
      HAVING EVERY(original_taxon_concept_id != taxon_concept_id)
    )
    UPDATE '|| tmp_lc_table_name || ' listing_changes_mview
    SET show_in_downloads = FALSE
    FROM taxon_concepts_with_inherited_legislation_only
    WHERE taxon_concepts_with_inherited_legislation_only.taxon_concept_id = listing_changes_mview.taxon_concept_id';

    EXECUTE sql;

    SELECT id INTO deletion_id FROM change_types WHERE name = 'DELETION' AND designation_id = designation.id;
    SELECT id INTO addition_id FROM change_types WHERE name = 'ADDITION' AND designation_id = designation.id;
    -- find inherited listing changes superceded by own listing changes
    -- mark them as not current in context of the child and add fake deletion records
    -- so that those inherited events are terminated properly on the timelines
    sql := 'WITH next_lc AS (
      SELECT taxon_concept_id, original_taxon_concept_id, species_listing_id, effective_at
      FROM ' || tmp_lc_table_name
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
      JOIN ' || tmp_lc_table_name || ' listing_changes_mview
      ON listing_changes_mview.taxon_concept_id = next_lc.taxon_concept_id
      AND change_type_id = ' || addition_id
      || ' AND listing_changes_mview.effective_at < next_lc.effective_at
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
      INSERT INTO ' || tmp_lc_table_name || ' (
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
    UPDATE ' || tmp_lc_table_name || ' SET is_current = FALSE
    FROM prev_lc terminated_lc
    WHERE terminated_lc.id = ' || tmp_lc_table_name || '.id
    AND terminated_lc.taxon_concept_id = ' || tmp_lc_table_name || '.taxon_concept_id';

    IF designation.name != 'CMS' THEN
      EXECUTE sql;
    END IF;

    -- current inclusions superceded by:
    -- deletions of higher taxa or self
    -- Notomys aquilo, Caracara lutosa, Sceloglaux albifacies
    -- other additions, including appendix transitions
    -- Moschus moschiferus moschiferus

    sql := 'WITH current_inclusions AS (
      SELECT * FROM ' || tmp_lc_table_name || '
      WHERE change_type_name = ''ADDITION''
      AND inclusion_taxon_concept_id IS NOT NULL
      AND is_current
      ), non_current_inclusions AS (
        SELECT current_inclusions.id, current_inclusions.taxon_concept_id
        FROM current_inclusions
        JOIN ' || tmp_lc_table_name || ' lc
        ON lc.change_type_name IN (''ADDITION'', ''DELETION'')
        AND lc.explicit_change
        AND lc.taxon_concept_id = current_inclusions.taxon_concept_id
        AND lc.effective_at > current_inclusions.effective_at
        AND lc.is_current
      )
      UPDATE ' || tmp_lc_table_name || ' lc
      SET is_current = FALSE
      FROM non_current_inclusions
      WHERE lc.id = non_current_inclusions.id
      AND lc.taxon_concept_id = non_current_inclusions.taxon_concept_id';

    EXECUTE sql;

    sql := 'WITH double_inclusions AS (
      SELECT lc.taxon_concept_id, lc.id AS own_inclusion_id, lc_inh.id AS inherited_inclusion_id,
      lc_inh.full_note_en AS inherited_full_note_en,
      lc_inh.short_note_en AS inherited_short_note_en,
      lc_inh.full_note_es AS inherited_full_note_es,
      lc_inh.short_note_es AS inherited_short_note_es,
      lc_inh.full_note_fr AS inherited_full_note_fr,
      lc_inh.short_note_fr AS inherited_short_note_fr
      FROM ' || tmp_lc_table_name || ' lc
      JOIN ' || tmp_lc_table_name || ' lc_inh
      ON lc.taxon_concept_id = lc_inh.taxon_concept_id
      AND lc.species_listing_id = lc_inh.species_listing_id
      AND lc.change_type_id = lc_inh.change_type_id
      AND lc.effective_at = lc_inh.effective_at
      AND (lc.party_id IS NULL OR lc.party_id = lc_inh.party_id)
      AND lc.inclusion_taxon_concept_id = lc_inh.original_taxon_concept_id
      WHERE lc.inclusion_taxon_concept_id IS NOT NULL
    ), rows_to_be_deleted AS (
      DELETE
      FROM ' || tmp_lc_table_name || ' lc
      USING double_inclusions
      WHERE double_inclusions.taxon_concept_id = lc.taxon_concept_id
      AND double_inclusions.inherited_inclusion_id = lc.id
      RETURNING *
    )
    UPDATE ' || tmp_lc_table_name || ' lc
    SET inherited_full_note_en = double_inclusions.inherited_full_note_en,
    inherited_short_note_en = double_inclusions.inherited_short_note_en,
    inherited_full_note_es = double_inclusions.inherited_full_note_es,
    inherited_short_note_es = double_inclusions.inherited_short_note_es,
    inherited_full_note_fr = double_inclusions.inherited_full_note_fr,
    inherited_short_note_fr = double_inclusions.inherited_short_note_fr
    FROM double_inclusions
    WHERE double_inclusions.taxon_concept_id = lc.taxon_concept_id
    AND double_inclusions.own_inclusion_id = lc.id
    AND (double_inclusions.inherited_full_note_en IS NOT NULL OR double_inclusions.inherited_short_note_en IS NOT NULL)';

    EXECUTE sql;

    RAISE INFO 'Creating indexes on %', tmp_lc_table_name;
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (show_in_timeline, taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (show_in_downloads, taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (original_taxon_concept_id)';
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' (is_current, change_type_name)'; -- Species+ downloads
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' USING GIN (listed_geo_entities_ids)'; -- search by geo entity
    EXECUTE 'CREATE INDEX ON ' || tmp_lc_table_name || ' USING GIN (excluded_geo_entities_ids)'; -- search by geo entity


    RAISE INFO 'Swapping %  materialized view', lc_table_name;
    EXECUTE 'DROP TABLE IF EXISTS ' || lc_table_name || ' CASCADE';
    EXECUTE 'ALTER TABLE ' || tmp_lc_table_name || ' RENAME TO ' || lc_table_name;
    IF designation.name != 'EU' THEN
      EXECUTE 'ALTER TABLE ' || lc_table_name || ' INHERIT ' || master_lc_table_name;
    END IF;
  END;
  $$;

COMMENT ON FUNCTION rebuild_designation_listing_changes_mview(
  taxonomy taxonomies, designation designations, events_ids INT[]
) IS
'Procedure to rebuild designation listing changes materialized view in the database.';
