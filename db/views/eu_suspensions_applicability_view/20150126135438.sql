WITH RECURSIVE eu_decisions_with_end_dates AS (
  SELECT
  eu_decisions.id,
  taxon_concept_id,
  geo_entity_id,
  term_id,
  source_id,
  start_event.effective_at AS start_event_date,
  end_event.effective_at AS end_event_date
  FROM eu_decisions
  JOIN events AS start_event ON start_event.id = eu_decisions.start_event_id
  LEFT JOIN events AS end_event ON end_event.id = eu_decisions.end_event_id
  WHERE eu_decisions.type = 'EuSuspension'
), eu_decisions_chain AS (
  SELECT eu_decisions_with_end_dates.*, eu_decisions_with_end_dates.start_event_date AS new_start_event_date
  FROM eu_decisions_with_end_dates
  WHERE end_event_date IS NULL

  UNION

  SELECT eu_decisions_chain.id,
  eu_decisions_chain.taxon_concept_id,
  eu_decisions_chain.geo_entity_id,
  eu_decisions_chain.term_id,
  eu_decisions_chain.source_id,
  eu_decisions_chain.start_event_date,
  eu_decisions_chain.end_event_date,
  eu_decisions_with_end_dates.start_event_date
  FROM eu_decisions_chain
  JOIN eu_decisions_with_end_dates
  ON eu_decisions_chain.taxon_concept_id = eu_decisions_with_end_dates.taxon_concept_id
  AND eu_decisions_chain.geo_entity_id = eu_decisions_with_end_dates.geo_entity_id
  AND (
    eu_decisions_chain.term_id = eu_decisions_with_end_dates.term_id
    OR eu_decisions_chain.term_id IS NULL AND eu_decisions_with_end_dates.term_id IS NULL
  )
  AND (
    eu_decisions_chain.source_id = eu_decisions_with_end_dates.source_id
    OR eu_decisions_chain.source_id IS NULL AND eu_decisions_with_end_dates.source_id IS NULL
  )
  AND eu_decisions_chain.new_start_event_date = eu_decisions_with_end_dates.end_event_date
)
SELECT
id,
MIN(new_start_event_date) AS original_start_date,
TO_CHAR(MIN(new_start_event_date), 'DD/MM/YYYY') AS original_start_date_formatted
FROM eu_decisions_chain GROUP BY id;
