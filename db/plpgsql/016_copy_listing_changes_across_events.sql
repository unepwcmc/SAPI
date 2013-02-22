CREATE OR REPLACE FUNCTION copy_listing_changes_across_events(
  from_event_id INTEGER, to_event_id INTEGER
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    WITH to_event AS (SELECT * FROM events WHERE id = to_event_id),
      copied_annotations AS (
      -- copy regular annotations
      INSERT INTO annotations (
        symbol, parent_symbol,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        created_at, updated_at
      )
      SELECT symbol, parent_symbol,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        current_date, current_date
      FROM annotations source
      INNER JOIN listing_changes
        ON listing_changes.annotation_id = source.id
          AND listing_changes.event_id = from_event_id
      RETURNING id, listing_changes.id AS source_listing_change_id
    ), copied_hash_annotations AS (
      -- copy hash annotations
      INSERT INTO annotations (
        symbol, parent_symbol,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        created_at, updated_at
      )
      SELECT symbol, parent_symbol,
        short_note_en, short_note_es, short_note_fr,
        full_note_en, full_note_es, full_note_fr,
        display_in_index, display_in_footnote,
        current_date, current_date
      FROM annotations source
      INNER JOIN listing_changes
        ON listing_changes.hash_annotation_id = source.id
          AND listing_changes.event_id = from_event_id
      RETURNING id, listing_changes.id AS source_listing_change_id
    ), copied_listing_changes AS (
      -- copy listing_changes
      INSERT INTO listing_changes (
        change_type_id, species_listing_id, annotation_id, hash_annotation_id,
        parent_id, event_id, effective_at, is_current, created_at, updated_at
      )
      SELECT source.change_type_id, source.species_listing_id,
        copied_annotations.id, copied_hash_annotations.id, source.parent_id,
        to_event_id, to_event.effective_at, false, current_date, current_date
      FROM listing_changes source
      LEFT JOIN copied_annotations
        ON source.id = copied_annotations.source_listing_change_id
      LEFT JOIN copied_hash_annotations
        ON source.id = copied_hash_annotations.source_listing_change_id
      RETURNING id, source.id AS source_id
    )
    INSERT INTO listing_distributions (
      listing_change_id, geo_entity_id, is_party, created_at, updated_at
    )
    SELECT copied_listing_changes.id, source.geo_entity_id, source.is_party,
      current_date, current_date
    FROM listing_distributions source
    INNER JOIN copied_listing_changes
      ON copied_listing_changes.source_id = listing_distributions.listing_change_id;
    END;
  $$;

COMMENT ON FUNCTION copy_listing_changes_across_events() IS
  'Procedure to copy listing changes across two events.'