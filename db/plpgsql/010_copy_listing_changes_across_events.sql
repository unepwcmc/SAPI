CREATE OR REPLACE FUNCTION copy_listing_changes_across_events(
  from_event_id INTEGER, to_event_id INTEGER
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      to_event events%ROWTYPE;
    BEGIN
    SELECT INTO to_event * FROM events WHERE id = to_event_id;


    WITH event_lcs AS (
      SELECT *
      FROM listing_changes
      WHERE event_id = from_event_id
    ), exclusions AS (
      SELECT listing_changes.*
      FROM event_lcs
      JOIN listing_changes
      ON event_lcs.id = listing_changes.parent_id
    ), lcs_to_copy AS (
      SELECT * FROM event_lcs
      UNION
      SELECT * FROM exclusions
    ), copied_annotations AS (
      -- copy regular annotations
      INSERT INTO annotations (
        symbol, parent_symbol,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        created_at, updated_at, original_id
      )
      SELECT symbol, parent_symbol,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        current_date, current_date, original.id
      FROM annotations original
      INNER JOIN lcs_to_copy lc
        ON lc.annotation_id = original.id
      RETURNING id, original_id
    ), copied_hash_annotations AS (
      -- copy hash annotations
      INSERT INTO annotations (
        symbol, parent_symbol, event_id,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        created_at, updated_at, original_id
      )
      SELECT DISTINCT symbol, to_event.name, to_event_id,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        current_date, current_date, original.id
      FROM annotations original
      JOIN lcs_to_copy lc
        ON lc.hash_annotation_id = original.id
      RETURNING id, original_id
    ), copied_listing_changes AS (
      -- copy listing_changes
      INSERT INTO listing_changes (
        change_type_id, species_listing_id, annotation_id, hash_annotation_id,
        parent_id, taxon_concept_id, event_id, effective_at, is_current,
        created_at, updated_at, original_id, created_by_id, updated_by_id
      )
      SELECT original.change_type_id, original.species_listing_id,
        copied_annotations.id, copied_hash_annotations.id, original.parent_id,
        original.taxon_concept_id, to_event.id, to_event.effective_at, to_event.is_current,
        current_date, current_date, original.id,
        events.created_by_id, events.updated_by_id
      FROM event_lcs original
      LEFT JOIN copied_annotations
        ON original.annotation_id = copied_annotations.original_id
      LEFT JOIN copied_hash_annotations
        ON original.hash_annotation_id = copied_hash_annotations.original_id
      JOIN events
        ON events.id = to_event_id
      RETURNING id, original_id, created_at, created_by_id, updated_at, updated_by_id
    ), copied_exclusions AS (
      INSERT INTO listing_changes (
        change_type_id, species_listing_id, annotation_id, hash_annotation_id,
        parent_id, taxon_concept_id, event_id, effective_at, is_current,
        created_at, updated_at, original_id, created_by_id, updated_by_id
      )
      SELECT original.change_type_id, original.species_listing_id,
        NULL, NULL, copied_listing_changes.id,
        original.taxon_concept_id, NULL, to_event.effective_at, to_event.is_current,
        copied_listing_changes.created_at, copied_listing_changes.updated_at, original.id,
        copied_listing_changes.created_by_id, copied_listing_changes.updated_by_id
      FROM exclusions original
      JOIN copied_listing_changes
      ON copied_listing_changes.original_id = original.parent_id
      RETURNING id, original_id, created_at, created_by_id, updated_at, updated_by_id
    )
    INSERT INTO listing_distributions (
      listing_change_id, geo_entity_id, is_party, created_at, updated_at
    )
    SELECT copied_listing_changes.id, original.geo_entity_id, original.is_party,
      current_date, current_date
    FROM listing_distributions original
    JOIN copied_listing_changes
      ON copied_listing_changes.original_id = original.listing_change_id
    UNION
    SELECT copied_exclusions.id, original.geo_entity_id, original.is_party,
      current_date, current_date
    FROM listing_distributions original
    JOIN copied_exclusions
      ON copied_exclusions.original_id = original.listing_change_id;

    END;
  $$;

COMMENT ON FUNCTION copy_listing_changes_across_events(from_event_id INTEGER, to_event_id INTEGER) IS
  'Procedure to copy listing changes across two events.'
