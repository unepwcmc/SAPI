DROP VIEW IF EXISTS api_eu_decisions_view;
CREATE VIEW api_eu_decisions_view AS
SELECT
eu_decisions.type,
eu_decisions.taxon_concept_id,
ROW_TO_JSON(
 ROW(
   taxon_concept_id,
   taxon_concepts.full_name,
   taxon_concepts.author_year,
   taxon_concepts.data->'rank_name'
 )::api_taxon_concept
) AS taxon_concept,
eu_decisions.notes,
CASE
  WHEN eu_decisions.type = 'EuOpinion'
  THEN eu_decisions.start_date
  WHEN eu_decisions.type = 'EuSuspension'
  THEN start_event.effective_at
END AS start_date,
CASE
  WHEN eu_decisions.type = 'EuOpinion'
  THEN eu_decisions.is_current
  WHEN eu_decisions.type = 'EuSuspension'
  THEN
    CASE
      WHEN start_event.effective_at <= current_date AND start_event.is_current = true
        AND (eu_decisions.end_event_id IS NULL OR end_event.effective_at > current_date)
      THEN TRUE
      ELSE
        FALSE
    END
END AS is_current,
eu_decisions.geo_entity_id,
ROW_TO_JSON(
  ROW(
    geo_entities.id,
    geo_entities.iso_code2,
    geo_entities.name_en,
    geo_entities.name_es,
    geo_entities.name_fr,
    ''
  )::api_geo_entity
) AS geo_entity,
eu_decisions.start_event_id,
ROW_TO_JSON(
  ROW(
    start_event.name,
    start_event.effective_at,
    start_event.url
  )::api_event
) AS start_event,
eu_decisions.end_event_id,
ROW_TO_JSON(
  ROW(
    end_event.name,
    end_event.effective_at,
    end_event.url
  )::api_event
) AS end_event,
eu_decisions.term_id,
ROW_TO_JSON(
  ROW(
    terms.id,
    terms.code,
    terms.name_en,
    terms.name_es,
    terms.name_fr
  )::api_trade_code
) AS term,
 ROW_TO_JSON(
  ROW(
    sources.id,
    sources.code,
    sources.name_en,
    sources.name_es,
    sources.name_fr
  )::api_trade_code
) AS source,
eu_decisions.source_id,
eu_decisions.eu_decision_type_id,
ROW_TO_JSON(
  ROW(
    eu_decision_types.id,
    eu_decision_types.name,
    eu_decision_types.tooltip,
    eu_decision_types.decision_type
  )::api_eu_decision_type
) AS eu_decision_type,
eu_decisions.nomenclature_note_en,
eu_decisions.nomenclature_note_fr,
eu_decisions.nomenclature_note_es
FROM eu_decisions
JOIN geo_entities ON geo_entities.id = eu_decisions.geo_entity_id
JOIN taxon_concepts ON taxon_concepts.id = eu_decisions.taxon_concept_id
LEFT JOIN events AS start_event ON start_event.id = eu_decisions.start_event_id
LEFT JOIN events AS end_event ON end_event.id = eu_decisions.end_event_id
LEFT JOIN trade_codes terms ON terms.id = eu_decisions.term_id AND terms.type = 'Term'
LEFT JOIN trade_codes sources ON sources.id = eu_decisions.source_id AND sources.type = 'Source'
LEFT JOIN eu_decision_types ON eu_decision_types.id = eu_decisions.eu_decision_type_id;
