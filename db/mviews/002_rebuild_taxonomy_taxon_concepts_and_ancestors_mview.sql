DROP FUNCTION IF EXISTS rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy taxonomies);

CREATE OR REPLACE FUNCTION rebuild_taxonomy_tmp_taxon_concepts_mview(taxonomy taxonomies) RETURNS void
  LANGUAGE plpgsql STRICT
  AS $$
  DECLARE
    tc_table_name TEXT;
    sql TEXT;
  BEGIN
    EXECUTE 'CREATE OR REPLACE VIEW ' || LOWER(taxonomy.name) || '_taxon_concepts_and_ancestors_view AS
    SELECT * FROM taxon_concepts_and_ancestors_mview
    WHERE taxonomy_id = ' || taxonomy.id;

    SELECT LOWER(taxonomy.name) || '_tmp_taxon_concepts_mview' INTO tc_table_name;

    EXECUTE 'DROP TABLE IF EXISTS ' || tc_table_name || ' CASCADE';

    sql := 'CREATE TEMP TABLE ' || tc_table_name || ' AS
    SELECT taxon_concepts.id,
    (data->''kingdom_id'')::INTEGER AS kingdom_id,
    (data->''phylum_id'')::INTEGER AS phylum_id,
    (data->''class_id'')::INTEGER AS class_id,
    (data->''order_id'')::INTEGER AS order_id,
    (data->''family_id'')::INTEGER AS family_id,
    (data->''subfamily_id'')::INTEGER AS subfamily_id,
    (data->''genus_id'')::INTEGER AS genus_id,
    (data->''species_id'')::INTEGER AS species_id,
    (data->''subspecies_id'')::INTEGER AS subspecies_id,
    countries_ids_ary
    FROM taxon_concepts
    LEFT JOIN taxonomies
    ON taxonomies.id = taxon_concepts.taxonomy_id
    LEFT JOIN (
      SELECT taxon_concepts.id AS taxon_concept_id_cnt,
      ARRAY(
        SELECT *
        FROM UNNEST(ARRAY_AGG(geo_entities.id ORDER BY geo_entities.name_en)) s
        WHERE s IS NOT NULL
      ) AS countries_ids_ary
      FROM taxon_concepts
      LEFT JOIN distributions
      ON "distributions"."taxon_concept_id" = "taxon_concepts"."id"
      LEFT JOIN geo_entities
      ON distributions.geo_entity_id = geo_entities.id
      GROUP BY taxon_concepts.id
    ) countries_ids ON taxon_concepts.id = countries_ids.taxon_concept_id_cnt
    WHERE taxonomy_id=$1';

    EXECUTE sql USING taxonomy.id;

    EXECUTE 'CREATE UNIQUE INDEX ON ' || tc_table_name || ' (id)';
  END
  $$;

COMMENT ON FUNCTION rebuild_taxonomy_tmp_taxon_concepts_mview(taxonomy taxonomies) IS
  'Procedure to create a helper table with all taxon ancestors and aggregated distributions in a given taxonomy.';
