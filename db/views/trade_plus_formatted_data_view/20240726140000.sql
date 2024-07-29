WITH unnested_rules AS (
  SELECT
    r.id AS rule_id,
    r.rule_priority,
    r.rule_name,

    CASE
      WHEN rule_type = 'standardise_terms'           THEN 1
      WHEN rule_type = 'standardise_units'           THEN 2
      WHEN rule_type = 'standardise_terms_and_units' THEN 3
      ELSE                                                4
    END AS rule_type_priority,

    r_terms.term_code,
    r_units.unit_code,

    (r.rule_input->>'taxon_filters') IS NOT NULL AS has_taxon_filters,

    (SELECT ARRAY_AGG(s) FROM jsonb_array_elements_text(r.rule_input->'taxon_filters'->'kingdom_names') a(s)) AS kingdom_names,
    (SELECT ARRAY_AGG(s) FROM jsonb_array_elements_text(r.rule_input->'taxon_filters'->'phylum_names')  a(s)) AS phylum_names,
    (SELECT ARRAY_AGG(s) FROM jsonb_array_elements_text(r.rule_input->'taxon_filters'->'class_names')   a(s)) AS class_names,
    (SELECT ARRAY_AGG(s) FROM jsonb_array_elements_text(r.rule_input->'taxon_filters'->'order_names')   a(s)) AS order_names,
    (SELECT ARRAY_AGG(s) FROM jsonb_array_elements_text(r.rule_input->'taxon_filters'->'family_names')  a(s)) AS family_names,
    (SELECT ARRAY_AGG(s) FROM jsonb_array_elements_text(r.rule_input->'taxon_filters'->'genus_names')   a(s)) AS genus_names,
    (SELECT ARRAY_AGG(s) FROM jsonb_array_elements_text(r.rule_input->'taxon_filters'->'taxon_names')   a(s)) AS taxon_names,
    (SELECT ARRAY_AGG(s) FROM jsonb_array_elements_text(r.rule_input->'taxon_filters'->'group_codes')   a(s)) AS group_codes,

    (r.rule_output->>'term')::TEXT              AS output_term_code,
    (r.rule_output->>'unit')::TEXT              AS output_unit_code,
    (r.rule_output->>'quantity_modifier')::TEXT AS quantity_modifier,
    (r.rule_output->>'modifier_value')::NUMERIC AS modifier_value
  FROM trade_conversion_rules r
  LEFT JOIN (
    SELECT r.id, jsonb_array_elements_text(r.rule_input->'terms') AS term_code
    FROM trade_conversion_rules r
  ) r_terms ON r_terms.id = r.id
  LEFT JOIN (
    SELECT r.id, jsonb_array_elements_text(r.rule_input->'units') AS unit_code
    FROM trade_conversion_rules r
  ) r_units ON r_units.id = r.id
  WHERE rule_type IN (
    'standardise_terms',
    'standardise_units',
    'standardise_terms_and_units'
  )
), unnested_rules_with_trade_codes AS (
  SELECT
    unnested_rules.*,

    term.id AS term_id,
    CASE WHEN output_term_code = 'NULL' THEN -1     ELSE output_term.id      END AS output_term_id,
    CASE WHEN output_term_code = 'NULL' THEN 'NULL' ELSE output_term.name_en END AS output_term_name_en,
    CASE WHEN output_term_code = 'NULL' THEN 'NULL' ELSE output_term.name_es END AS output_term_name_es,
    CASE WHEN output_term_code = 'NULL' THEN 'NULL' ELSE output_term.name_fr END AS output_term_name_fr,

    unit.id AS unit_id,
    CASE WHEN output_unit_code = 'NULL' THEN -1     ELSE output_unit.id      END AS output_unit_id,
    CASE WHEN output_unit_code = 'NULL' THEN 'NULL' ELSE output_unit.name_en END AS output_unit_name_en,
    CASE WHEN output_unit_code = 'NULL' THEN 'NULL' ELSE output_unit.name_es END AS output_unit_name_es,
    CASE WHEN output_unit_code = 'NULL' THEN 'NULL' ELSE output_unit.name_fr END AS output_unit_name_fr
  FROM unnested_rules
  LEFT JOIN trade_codes term ON term.code = term_code AND term.type = 'Term'
  LEFT JOIN trade_codes unit ON unit.code = unit_code AND unit.type = 'Unit'
  LEFT JOIN trade_codes output_term ON output_term.code = output_term_code AND output_term.type = 'Term'
  LEFT JOIN trade_codes output_unit ON output_unit.code = output_unit_code AND output_unit.type = 'Unit'
)
-- Use DISTINCT ON, as it is possible for multiple rules to match,
-- e.g. term=COR, unit=NAR (* 0.58, kg); unit=NAR (* 1). In this case,
-- we expect the first matching rule to apply.
SELECT DISTINCT ON (ts.id)
  ts.id                         AS id,
  ts.year                       AS year,
  ts.appendix                   AS appendix,
  ts.reported_by_exporter       AS reported_by_exporter,
  ts.taxon_concept_id           AS taxon_id,
  ts.taxon_concept_author_year  AS author_year,
  ts.taxon_concept_name_status  AS name_status,
  ts.taxon_concept_full_name    AS taxon_name,
  ts.taxon_concept_kingdom_name AS kingdom_name,
  ts.taxon_concept_kingdom_id   AS kingdom_id,
  ts.taxon_concept_phylum_name  AS phylum_name,
  ts.taxon_concept_phylum_id    AS phylum_id,
  ts.taxon_concept_class_name   AS class_name,
  ts.taxon_concept_class_id     AS class_id,
  ts.taxon_concept_order_name   AS order_name,
  ts.taxon_concept_order_id     AS order_id,
  ts.taxon_concept_family_name  AS family_name,
  ts.taxon_concept_family_id    AS family_id,
  ts.taxon_concept_genus_name   AS genus_name,
  ts.taxon_concept_genus_id     AS genus_id,
  ts.group_en                   AS group_name_en,
  ts.group_es                   AS group_name_es,
  ts.group_fr                   AS group_name_fr,
  ts.quantity                   AS quantity,
  ts.taxon_concept_rank_id      AS taxon_concept_rank_id,
  ts.source_id                  AS source_id,
  ts.purpose_id                 AS purpose_id,

  -- mapping Taiwan trades to China trades, so that they appear as the same country on Tradeplus
  CASE WHEN ts.importer_id = 218 THEN 160
  ELSE ts.importer_id
  END AS china_importer_id,
  CASE WHEN ts.exporter_id = 218 THEN 160
  ELSE ts.exporter_id
  END AS china_exporter_id,
  CASE WHEN ts.country_of_origin_id = 218 THEN 160
  ELSE ts.country_of_origin_id
  END AS china_origin_id,

  ts.term_id      AS original_term_id,
  terms.code      AS original_term_code,
  terms.name_en   AS original_term_en,
  ts.unit_id      AS original_unit_id,
  units.code      AS original_unit_code,
  units.name_en   AS original_unit_en,

  -- Replacing NULLs with values from related rows when possible.
  -- Moreover, if ids are -1 or codes/names are 'NULL' strings, replace those with NULL
  -- after the processing is done. This is to get back to just a unique NULL representation.

  NULLIF(COALESCE(r.output_term_id,      ts.term_id),        -1) AS term_id,
  NULLIF(COALESCE(r.output_term_code,    terms.code),    'NULL') AS term_code,
  NULLIF(COALESCE(r.output_term_name_en, terms.name_en), 'NULL') AS term_en,
  NULLIF(COALESCE(r.output_term_name_es, terms.name_es), 'NULL') AS term_es,
  NULLIF(COALESCE(r.output_term_name_fr, terms.name_fr), 'NULL') AS term_fr,
  NULLIF(COALESCE(r.output_unit_id,      ts.unit_id),        -1) AS unit_id,
  NULLIF(COALESCE(r.output_unit_code,    units.code),    'NULL') AS unit_code,
  NULLIF(COALESCE(r.output_unit_name_en, units.name_en), 'NULL') AS unit_en,
  NULLIF(COALESCE(r.output_unit_name_es, units.name_es), 'NULL') AS unit_es,
  NULLIF(COALESCE(r.output_unit_name_fr, units.name_fr), 'NULL') AS unit_fr,

  rule_id, ts.group_code,

  quantity_modifier     AS quantity_modifier,
  modifier_value::FLOAT AS modifier_value
FROM trade_plus_group_view ts
LEFT OUTER JOIN unnested_rules_with_trade_codes r ON (
  (r.unit_code IS NULL OR (r.unit_code = 'NULL' AND ts.unit_id IS NULL) OR r.unit_id = ts.unit_id)
  AND
  (r.term_code IS NULL OR (r.term_code = 'NULL' AND ts.term_id IS NULL) OR r.term_id = ts.term_id)
  AND (
    NOT has_taxon_filters
    OR ts.taxon_concept_kingdom_name = ANY(r.kingdom_names)
    OR ts.taxon_concept_phylum_name = ANY(r.phylum_names)
    OR ts.taxon_concept_class_name = ANY(r.class_names)
    OR ts.taxon_concept_order_name = ANY(r.order_names)
    OR ts.taxon_concept_family_name = ANY(r.family_names)
    OR ts.taxon_concept_genus_name = ANY(r.genus_names)
    OR ts.taxon_concept_full_name = ANY(r.taxon_names) -- note full name is neither taxon_name nor species_name
    OR ts.group_code = ANY(r.group_codes)
  )
)

LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id

ORDER BY ts.id, r.rule_type_priority, r.rule_priority, r.rule_id
