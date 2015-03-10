WITH RECURSIVE eu_decisions_by_date AS (
  SELECT
  eu_decisions.id,
  taxon_concept_id,
  geo_entity_id,
  term_id,
  source_id,
  start_date,
  start_event.effective_at AS start_event_date,
  eu_decisions.end_date,
  end_event.effective_at AS end_event_date,
  ROW_NUMBER() OVER (PARTITION BY taxon_concept_id, geo_entity_id, term_id, source_id ORDER BY start_date)
  FROM eu_decisions
  LEFT JOIN events AS start_event ON start_event.id = eu_decisions.start_event_id
  LEFT JOIN events AS end_event ON end_event.id = eu_decisions.end_event_id
  WHERE eu_decisions.type = 'EuSuspension'
), eu_decisions_with_end_dates AS (
  SELECT
  eu_decisions.id,
  eu_decisions.taxon_concept_id,
  eu_decisions.geo_entity_id,
  eu_decisions.term_id,
  eu_decisions.source_id,
  eu_decisions.start_event_date AS start_event_date,
  CASE
    -- if the eu decision has a terminating event, use that date
    WHEN eu_decisions.end_event_date IS NOT NULL
    THEN eu_decisions.end_event_date
    -- if there is no terminating event and also no subsequent suspension, this is probably valid
    WHEN newer_eu_decisions.start_event_date IS NULL
    THEN NULL
    -- if there is a subsequent suspension in the following year, it is likely the terminating event
    WHEN EXTRACT('year' FROM newer_eu_decisions.start_event_date) = (EXTRACT('year' FROM eu_decisions.start_event_date) + 1)
    THEN newer_eu_decisions.start_event_date
    -- in 2002 there was no suspension regulation published, leading to this excellent edge case
    WHEN EXTRACT('year' FROM eu_decisions.start_event_date) = 2001 AND (
      EXTRACT('year' FROM newer_eu_decisions.start_event_date) = 2001
      OR EXTRACT('year' FROM newer_eu_decisions.start_event_date) = 2003
    )
    THEN newer_eu_decisions.start_event_date
    -- if there is a subsequent suspension but later than in following year, assume this one terminated by the end of year
    ELSE (EXTRACT('year' FROM eu_decisions.start_event_date) || '-12-31')::TIMESTAMP
  END AS end_event_date
  FROM eu_decisions_by_date eu_decisions
  LEFT JOIN eu_decisions_by_date newer_eu_decisions
  ON eu_decisions.taxon_concept_id = newer_eu_decisions.taxon_concept_id
  AND eu_decisions.geo_entity_id = newer_eu_decisions.geo_entity_id
  AND (eu_decisions.term_id = newer_eu_decisions.term_id OR eu_decisions.term_id IS NULL AND newer_eu_decisions.term_id IS NULL)
  AND (eu_decisions.source_id = newer_eu_decisions.source_id OR eu_decisions.source_id IS NULL AND newer_eu_decisions.source_id IS NULL)
  AND eu_decisions.row_number = (newer_eu_decisions.row_number - 1)
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
  eu_decisions_chain.start_event_date, eu_decisions_chain.end_event_date, eu_decisions_with_end_dates.start_event_date
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
