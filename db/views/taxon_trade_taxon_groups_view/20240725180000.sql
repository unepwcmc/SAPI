WITH rule AS (
  SELECT
    rule.id trade_conversion_rule_id,
    rule.rule_name,
    rule.rule_priority,

    taxon_group.id      trade_taxon_group_id,
    taxon_group.code    trade_taxon_group_code,
    taxon_group.name_en trade_taxon_group_name_en,
    taxon_group.name_es trade_taxon_group_name_es,
    taxon_group.name_fr trade_taxon_group_name_fr,

    ARRAY(SELECT jsonb_array_elements_text(rule.rule_input->'kingdom_names'))::TEXT[] AS kingdom_names,
    ARRAY(SELECT jsonb_array_elements_text(rule.rule_input->'phylum_names'))::TEXT[] AS phylum_names,
    ARRAY(SELECT jsonb_array_elements_text(rule.rule_input->'class_names'))::TEXT[] AS class_names,
    ARRAY(SELECT jsonb_array_elements_text(rule.rule_input->'order_names'))::TEXT[] AS order_names,
    ARRAY(SELECT jsonb_array_elements_text(rule.rule_input->'family_names'))::TEXT[] AS family_names,
    ARRAY(SELECT jsonb_array_elements_text(rule.rule_input->'genus_names'))::TEXT[] AS genus_names,
    ARRAY(SELECT jsonb_array_elements_text(rule.rule_input->'taxon_names'))::TEXT[] AS taxon_names,
    rule.rule_output->'group' AS output_group_code
  FROM trade_conversion_rules rule
  JOIN trade_taxon_groups taxon_group
    ON rule_type = 'taxon_group'
    AND (rule.rule_output->>'group')::TEXT = taxon_group.code
)
SELECT DISTINCT ON (taxon.id)
  taxon.id AS taxon_concept_id,
  trade_conversion_rule_id,
  trade_taxon_group_id,
  trade_taxon_group_code,
  trade_taxon_group_name_en,
  trade_taxon_group_name_es,
  trade_taxon_group_name_fr
FROM
  taxon_concepts taxon
JOIN rule
  ON (
    (taxon.data->'kingdom_name') = ANY(rule.kingdom_names) OR
    (taxon.data->'phylum_name') = ANY(rule.phylum_names) OR
    (taxon.data->'class_name') = ANY(rule.class_names) OR
    (taxon.data->'order_name') = ANY(rule.order_names) OR
    (taxon.data->'family_name') = ANY(rule.family_names) OR
    (taxon.data->'genus_name') = ANY(rule.genus_names) OR
    taxon.full_name = ANY(rule.taxon_names)
  )
ORDER BY
  taxon.id,
  rule.rule_priority