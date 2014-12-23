SELECT
  taxon_concept_id,
  taxon_concepts.taxonomic_position,
  (taxon_concepts.data->'kingdom_id')::INT AS kingdom_id,
  (taxon_concepts.data->'phylum_id')::INT AS phylum_id,
  (taxon_concepts.data->'class_id')::INT AS class_id,
  (taxon_concepts.data->'order_id')::INT AS order_id,
  (taxon_concepts.data->'family_id')::INT AS family_id,
  taxon_concepts.data->'kingdom_name' AS kingdom_name,
  taxon_concepts.data->'phylum_name' AS phylum_name,
  taxon_concepts.data->'class_name' AS class_name,
  taxon_concepts.data->'order_name' AS order_name,
  taxon_concepts.data->'family_name' AS family_name,
  taxon_concepts.data->'genus_name' AS genus_name,
  LOWER(taxon_concepts.data->'species_name') AS species_name,
  LOWER(taxon_concepts.data->'subspecies_name') AS subspecies_name,
  taxon_concepts.full_name AS full_name,
  taxon_concepts.data->'rank_name' AS rank_name,
  eu_decisions.start_date,
  TO_CHAR(eu_decisions.start_date, 'DD/MM/YYYY') AS start_date_formatted,
  geo_entity_id,
  geo_entities.name_en AS party,
  CASE
    WHEN eu_decision_types.name ~* '^i+\)'
    THEN '(No opinion) ' || eu_decision_types.name
    ELSE eu_decision_types.name
  END AS decision_type_for_display,
  eu_decision_types.decision_type AS decision_type,
  sources.name_en AS source_name,
  sources.code || ' - ' || sources.name_en AS source_code_and_name,
  terms.name_en AS term_name,
  eu_decisions.notes,
  start_event.name AS start_event_name,
  CASE
    WHEN (
      eu_decisions.type = 'EuOpinion' AND eu_decisions.is_current
    )
    OR (
      eu_decisions.type = 'EuSuspension'
      AND start_event.effective_at < current_date
      AND start_event.is_current = true
      AND (eu_decisions.end_event_id IS NULL OR end_event.effective_at > current_date)
    )
    THEN TRUE
    ELSE FALSE
  END AS is_valid,
  CASE
    WHEN (
      eu_decisions.type = 'EuOpinion' AND eu_decisions.is_current
    )
    OR (
      eu_decisions.type = 'EuSuspension'
      AND start_event.effective_at < current_date
      AND start_event.is_current = true
      AND (eu_decisions.end_event_id IS NULL OR end_event.effective_at > current_date)
    )
    THEN 'Valid'
    ELSE 'Not Valid'
  END AS is_valid_for_display,
  CASE
    WHEN eu_decisions.type = 'EuOpinion'
      THEN eu_decisions.start_date
    WHEN eu_decisions.type = 'EuSuspension'
      THEN start_event.effective_at
  END AS ordering_date,
  CASE
    WHEN LENGTH(eu_decisions.notes) > 0 THEN strip_tags(eu_decisions.notes) || E'\n'
    ELSE ''
  END
  || CASE
    WHEN LENGTH(eu_decisions.nomenclature_note_en) > 0 THEN strip_tags(eu_decisions.nomenclature_note_en)
    ELSE ''
  END AS full_note_en
FROM eu_decisions
JOIN eu_decision_types ON eu_decision_types.id = eu_decisions.eu_decision_type_id
JOIN taxon_concepts ON taxon_concepts.id = eu_decisions.taxon_concept_id
LEFT JOIN events AS start_event ON start_event.id = eu_decisions.start_event_id
LEFT JOIN events AS end_event ON end_event.id = eu_decisions.end_event_id
LEFT JOIN geo_entities ON geo_entities.id = eu_decisions.geo_entity_id
LEFT JOIN trade_codes sources ON sources.type = 'Source' AND sources.id = eu_decisions.source_id
LEFT JOIN trade_codes terms ON terms.type = 'Term' AND terms.id = eu_decisions.term_id;
