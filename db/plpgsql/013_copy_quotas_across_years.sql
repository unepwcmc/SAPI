CREATE OR REPLACE FUNCTION copy_quotas_across_years(
  from_year INTEGER, new_start_date DATE, new_end_date DATE, new_publication_date DATE,
  excluded_taxon_concepts_ids INTEGER[], included_taxon_concepts_ids INTEGER[],
  excluded_geo_entities_ids INTEGER[], included_geo_entities_ids INTEGER[],
  from_text VARCHAR, to_text VARCHAR
  ) RETURNS VOID
  LANGUAGE plpgsql
  AS $$
DECLARE
   included_taxon_concepts INTEGER[];
   excluded_taxon_concepts INTEGER[];
   included_geo_entities INTEGER[];
   excluded_geo_entities INTEGER[];
   cites_taxonomy_id INTEGER;
   updated_rows INTEGER;
BEGIN
    SELECT id into cites_taxonomy_id FROM taxonomies WHERE name = 'CITES_EU';

    -- fetch included_taxon_concepts
    WITH RECURSIVE self_and_descendants(id, full_name) AS (
      SELECT id, full_name FROM taxon_concepts
      WHERE included_taxon_concepts_ids @> ARRAY[id] AND taxonomy_id = cites_taxonomy_id

      UNION

      SELECT hi.id, hi.full_name FROM taxon_concepts hi
      JOIN self_and_descendants d ON d.id = hi.parent_id
      WHERE  hi.taxonomy_id = cites_taxonomy_id
    )
    SELECT array_agg(id) INTO included_taxon_concepts FROM self_and_descendants;

    -- fetch excluded_taxon_concepts
    WITH RECURSIVE self_and_descendants(id, full_name) AS (
      SELECT id, full_name FROM taxon_concepts
      WHERE excluded_taxon_concepts_ids @> ARRAY[id] AND taxonomy_id = cites_taxonomy_id

      UNION

      SELECT hi.id, hi.full_name FROM taxon_concepts hi
      JOIN self_and_descendants d ON d.id = hi.parent_id
    )
    SELECT array_agg(id) INTO excluded_taxon_concepts FROM self_and_descendants;

    -- fetch included geo entities
    SELECT array_agg(matches.id) INTO included_geo_entities
    FROM (
      SELECT geo_entities.id FROM geo_entities
      WHERE included_geo_entities_ids @> ARRAY[id]
      UNION
      SELECT geo_entities.id FROM geo_entities
      INNER JOIN geo_relationships ON geo_relationships.other_geo_entity_id = geo_entities.id
        AND included_geo_entities_ids @> ARRAY[geo_relationships.geo_entity_id]
      INNER JOIN geo_relationship_types ON geo_relationship_types.id = geo_relationships.geo_relationship_type_id
        AND geo_relationship_types.name = 'CONTAINS'
    ) AS matches;

    -- fetch excluded geo entities
    SELECT array_agg(matches.id) INTO excluded_geo_entities
    FROM (
      SELECT geo_entities.id FROM geo_entities
      WHERE excluded_geo_entities_ids @> ARRAY[id]
      UNION
      SELECT geo_entities.id FROM geo_entities
      INNER JOIN geo_relationships ON geo_relationships.other_geo_entity_id = geo_entities.id
        AND excluded_geo_entities_ids @> ARRAY[geo_relationships.geo_entity_id]
      INNER JOIN geo_relationship_types ON geo_relationship_types.id = geo_relationships.geo_relationship_type_id
        AND geo_relationship_types.name = 'CONTAINS'
    ) AS matches;

    WITH original_current_quotas AS (
      SELECT *
      FROM trade_restrictions
      WHERE type = 'Quota' AND EXTRACT(year FROM start_date) =  from_year AND is_current = true
      AND (ARRAY_LENGTH(excluded_taxon_concepts, 1) IS NULL OR NOT excluded_taxon_concepts @> ARRAY[taxon_concept_id])
      AND (ARRAY_LENGTH(included_taxon_concepts, 1) IS NULL OR included_taxon_concepts @> ARRAY[taxon_concept_id])	
      AND (ARRAY_LENGTH(excluded_geo_entities, 1) IS NULL OR NOT excluded_geo_entities @> ARRAY[geo_entity_id])
      AND (ARRAY_LENGTH(included_geo_entities, 1) IS NULL OR included_geo_entities  @> ARRAY[geo_entity_id])
    ), updated_quotas AS (
      UPDATE trade_restrictions
      SET is_current = false
      FROM original_current_quotas
      WHERE trade_restrictions.id = original_current_quotas.id
    )
    INSERT INTO trade_restrictions(type, is_current, start_date, end_date, geo_entity_id, quota,
    publication_date, notes, unit_id, taxon_concept_id, public_display, url, created_at, updated_at,
    excluded_taxon_concepts_ids)
    SELECT 'Quota', is_current, new_start_date, new_end_date, geo_entity_id, quota,
    new_publication_date,
    CASE
      WHEN LENGTH(from_text) = 0
      THEN notes
    ELSE
      REPLACE(notes, from_text, to_text)
    END, unit_id, taxon_concept_id, public_display, url, current_date,
    current_date, trade_restrictions.excluded_taxon_concepts_ids
    FROM original_current_quotas AS trade_restrictions;

    GET DIAGNOSTICS updated_rows = ROW_COUNT;
    RAISE INFO '[%] Copied % quotas', 'trade_transactions', updated_rows;
  END;
$$;

COMMENT ON FUNCTION copy_quotas_across_years(
  from_year INTEGER, new_start_date DATE, new_end_date DATE,
  new_publication_date DATE, excluded_taxon_concepts_ids INTEGER[],
  included_taxon_concepts_ids INTEGER[], excluded_geo_entities_ids INTEGER[],
  included_geo_entities_ids INTEGER[], from_text VARCHAR, to_text VARCHAR) IS
  'Procedure to copy quotas across two years with some filtering parameters.';
