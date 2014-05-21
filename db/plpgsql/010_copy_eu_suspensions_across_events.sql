CREATE OR REPLACE FUNCTION copy_eu_suspensions_across_events(
  from_event_id INTEGER, to_event_id INTEGER
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      to_event events%ROWTYPE;
    BEGIN

    SELECT INTO to_event * FROM events WHERE id = to_event_id;

    -- copy eu_suspensions
    INSERT INTO eu_decisions (
      is_current, notes, internal_notes, taxon_concept_id, geo_entity_id,
      start_date, start_event_id, end_date, end_event_id, type, 
      conditions_apply, created_at, updated_at, eu_decision_type_id, 
      term_id, source_id, created_by_id, updated_by_id
    )
    SELECT true, source.notes, source.internal_notes, 
      source.taxon_concept_id, source.geo_entity_id, 
      to_event.effective_at, to_event_id, null, null, source.type, 
      source.conditions_apply, current_date, current_date, 
      source.eu_decision_type_id, source.term_id, source_id, 
      events.created_by_id, events.updated_by_id
    FROM eu_decisions source
    JOIN events
    ON events.id = to_event_id
    WHERE source.start_event_id = from_event_id  AND source.type = 'EuSuspension';

    UPDATE eu_decisions SET end_event_id = to_event.id 
    WHERE start_event_id = from_event_id AND type = 'EuSuspension';

    END;
  $$;

COMMENT ON FUNCTION copy_eu_suspensions_across_events(from_event_id INTEGER, to_event_id INTEGER) IS
  'Procedure to copy eu suspensions across two events.'
