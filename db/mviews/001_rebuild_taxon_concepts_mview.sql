CREATE OR REPLACE FUNCTION rebuild_taxon_concepts_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    DROP table IF EXISTS taxon_concepts_mview_tmp CASCADE;
    DROP view IF EXISTS taxon_concepts_view_tmp;

    CREATE OR REPLACE VIEW taxon_concepts_view_tmp AS
    SELECT taxon_concepts.id,
    taxon_concepts.parent_id,
    taxon_concepts.taxonomy_id,
    CASE
    WHEN taxonomies.name = 'CITES_EU' THEN TRUE
    ELSE FALSE
    END AS taxonomy_is_cites_eu,
    full_name,
    name_status,
    rank_id,
    ranks.name AS rank_name,
    ranks.display_name_en AS rank_display_name_en,
    ranks.display_name_es AS rank_display_name_es,
    ranks.display_name_fr AS rank_display_name_fr,
    (data->'spp')::BOOLEAN AS spp,
    (data->'cites_accepted')::BOOLEAN AS cites_accepted,
    CASE
    WHEN data->'kingdom_name' = 'Animalia' THEN 0
    ELSE 1
    END AS kingdom_position,
    taxon_concepts.taxonomic_position,
    data->'kingdom_name' AS kingdom_name,
    data->'phylum_name' AS phylum_name,
    data->'class_name' AS class_name,
    data->'order_name' AS order_name,
    data->'family_name' AS family_name,
    data->'subfamily_name' AS subfamily_name,
    data->'genus_name' AS genus_name,
    LOWER(data->'species_name') AS species_name,
    LOWER(data->'subspecies_name') AS subspecies_name,
    (data->'kingdom_id')::INTEGER AS kingdom_id,
    (data->'phylum_id')::INTEGER AS phylum_id,
    (data->'class_id')::INTEGER AS class_id,
    (data->'order_id')::INTEGER AS order_id,
    (data->'family_id')::INTEGER AS family_id,
    (data->'subfamily_id')::INTEGER AS subfamily_id,
    (data->'genus_id')::INTEGER AS genus_id,
    (data->'species_id')::INTEGER AS species_id,
    (data->'subspecies_id')::INTEGER AS subspecies_id,
    CASE
    WHEN listing->'cites_I' = 'I' THEN TRUE
    ELSE FALSE
    END AS cites_I,
    CASE
    WHEN listing->'cites_II' = 'II' THEN TRUE
    ELSE FALSE
    END AS cites_II,
    CASE
    WHEN listing->'cites_III' = 'III' THEN TRUE
    ELSE FALSE
    END AS cites_III,
    CASE
    WHEN listing->'cites_status' = 'LISTED' AND listing->'cites_level_of_listing' = 't'
    THEN TRUE
    WHEN listing->'cites_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
    END AS cites_listed,
    (listing->'cites_listed_descendants')::BOOLEAN AS cites_listed_descendants,
    (listing->'cites_show')::BOOLEAN AS cites_show,
    --(listing->'cites_status_original')::BOOLEAN AS cites_status_original, --doesn't seem to be used
    listing->'cites_status' AS cites_status,
    listing->'cites_listing_original' AS cites_listing_original, --used in CSV downloads
    listing->'cites_listing' AS cites_listing,
    (listing->'cites_listing_updated_at')::TIMESTAMP AS cites_listing_updated_at,
    (listing->'ann_symbol') AS ann_symbol,
    (listing->'hash_ann_symbol') AS hash_ann_symbol,
    (listing->'hash_ann_parent_symbol') AS hash_ann_parent_symbol,
    CASE
    WHEN listing->'eu_status' = 'LISTED' AND listing->'eu_level_of_listing' = 't'
    THEN TRUE
    WHEN listing->'eu_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
    END AS eu_listed,
    (listing->'eu_show')::BOOLEAN AS eu_show,
    --(listing->'eu_status_original')::BOOLEAN AS eu_status_original, --doesn't seem to be used
    listing->'eu_status' AS eu_status,
    listing->'eu_listing_original' AS eu_listing_original,
    listing->'eu_listing' AS eu_listing,
    (listing->'eu_listing_updated_at')::TIMESTAMP AS eu_listing_updated_at,
    CASE
    WHEN listing->'cms_status' = 'LISTED' AND listing->'cms_level_of_listing' = 't'
    THEN TRUE
    WHEN listing->'cms_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
    END AS cms_listed,
    (listing->'cms_show')::BOOLEAN AS cms_show,
    listing->'cms_status' AS cms_status,
    listing->'cms_listing_original' AS cms_listing_original,
    listing->'cms_listing' AS cms_listing,
    (listing->'cms_listing_updated_at')::TIMESTAMP AS cms_listing_updated_at,
    (listing->'species_listings_ids')::INT[] AS species_listings_ids,
    (listing->'species_listings_ids_aggregated')::INT[] AS species_listings_ids_aggregated,
    author_year,
    taxon_concepts.created_at,
    taxon_concepts.updated_at,
    common_names.*,
    synonyms.*,
    subspecies.subspecies_ary,
    countries_ids_ary,
    CASE
      WHEN
        name_status = 'A'
        AND (
          ranks.name != 'SUBSPECIES'
          AND ranks.name != 'VARIETY'
          OR (listing->'cites_show')::BOOLEAN
        )
      THEN TRUE
      ELSE FALSE
    END AS show_in_species_plus_ac,
    CASE
      WHEN
        name_status = 'A'
        AND listing->'cites_status' != 'LISTED'
        AND (
          ranks.name != 'SUBSPECIES'
          AND ranks.name != 'VARIETY'
          OR (listing->'cites_show')::BOOLEAN
        )
      THEN TRUE
      ELSE FALSE
    END AS show_in_checklist_ac,
    CASE
      WHEN
        taxonomies.name = 'CITES_EU'
        AND ARRAY['A', 'H', 'T']::VARCHAR[] && ARRAY[name_status]
      THEN TRUE
      ELSE FALSE
    END AS show_in_trade_ac
    FROM taxon_concepts
    JOIN ranks ON ranks.id = rank_id
    JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
    LEFT JOIN (
      SELECT *
      FROM
      CROSSTAB(
      'SELECT taxon_concepts.id AS taxon_concept_id_com, languages.iso_code1 AS lng,
      ARRAY_AGG(common_names.name ORDER BY common_names.name) AS common_names_ary
      FROM "taxon_concepts"
      INNER JOIN "taxon_commons"
      ON "taxon_commons"."taxon_concept_id" = "taxon_concepts"."id"
      INNER JOIN "common_names"
      ON "common_names"."id" = "taxon_commons"."common_name_id"
      INNER JOIN "languages"
      ON "languages"."id" = "common_names"."language_id" AND UPPER(languages.iso_code1) IN (''EN'', ''FR'', ''ES'')
      GROUP BY taxon_concepts.id, languages.iso_code1
      ORDER BY 1,2',
      'SELECT DISTINCT languages.iso_code1 FROM languages WHERE UPPER(languages.iso_code1) IN (''EN'', ''FR'', ''ES'') order by 1'
      ) AS ct(
      taxon_concept_id_com INTEGER,
      english_names_ary VARCHAR[], spanish_names_ary VARCHAR[], french_names_ary VARCHAR[]
      )
    ) common_names ON taxon_concepts.id = common_names.taxon_concept_id_com
    LEFT JOIN (
      SELECT taxon_concepts.id AS taxon_concept_id_syn,
      ARRAY_AGG_NOTNULL(synonym_tc.full_name) AS synonyms_ary,
      ARRAY_AGG_NOTNULL(synonym_tc.author_year) AS synonyms_author_years_ary
      FROM taxon_concepts
      LEFT JOIN taxon_relationships
      ON "taxon_relationships"."taxon_concept_id" = "taxon_concepts"."id"
      LEFT JOIN "taxon_relationship_types"
      ON "taxon_relationship_types"."id" = "taxon_relationships"."taxon_relationship_type_id"
      LEFT JOIN taxon_concepts AS synonym_tc
      ON synonym_tc.id = taxon_relationships.other_taxon_concept_id
      AND "taxon_relationship_types"."name" = 'HAS_SYNONYM'
      GROUP BY taxon_concepts.id
    ) synonyms ON taxon_concepts.id = synonyms.taxon_concept_id_syn
    LEFT JOIN (
      SELECT taxon_concepts.parent_id AS taxon_concept_id_sub,
      ARRAY_AGG(taxon_concepts.full_name) AS subspecies_ary
      FROM taxon_concepts
      JOIN ranks ON ranks.id = taxon_concepts.rank_id
      AND ranks.name IN ('SUBSPECIES', 'VARIETY')
      WHERE name_status != 'S'
      GROUP BY taxon_concepts.parent_id
    ) subspecies ON taxon_concepts.id = subspecies.taxon_concept_id_sub
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
      LEFT JOIN "geo_entity_types"
      ON "geo_entity_types"."id" = "geo_entities"."geo_entity_type_id"
      AND (geo_entity_types.name = 'COUNTRY' OR geo_entity_types.name = 'TERRITORY')
      GROUP BY taxon_concepts.id
    ) countries_ids ON taxon_concepts.id = countries_ids.taxon_concept_id_cnt;

    RAISE INFO 'Creating taxon concepts materialized view (tmp)';
    CREATE TABLE taxon_concepts_mview_tmp AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM taxon_concepts_view_tmp;

    RAISE INFO 'Creating indexes on taxon_concepts materialized view (tmp)';
    CREATE INDEX ON taxon_concepts_mview_tmp (id);
    CREATE INDEX ON taxon_concepts_mview_tmp (parent_id);
    CREATE INDEX ON taxon_concepts_mview_tmp (taxonomy_is_cites_eu, cites_listed, kingdom_position);
    CREATE INDEX ON taxon_concepts_mview_tmp (cms_show, name_status, cms_listing_original, taxonomy_is_cites_eu, rank_name); -- cms csv download
    CREATE INDEX ON taxon_concepts_mview_tmp (cites_show, name_status, cites_listing_original, taxonomy_is_cites_eu, rank_name); -- cites csv download
    CREATE INDEX ON taxon_concepts_mview_tmp (eu_show, name_status, eu_listing_original, taxonomy_is_cites_eu, rank_name); -- eu csv download

    --this one used for Species+ autocomplete (both main and higher taxa in downloads)
    CREATE INDEX ON taxon_concepts_mview_tmp USING BTREE(UPPER(full_name) text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_species_plus_ac);
    --this one used for Checklist autocomplete
    CREATE INDEX ON taxon_concepts_mview_tmp USING BTREE(UPPER(full_name) text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_checklist_ac);
    --this one used for Trade autocomplete
    CREATE INDEX ON taxon_concepts_mview_tmp USING BTREE(UPPER(full_name) text_pattern_ops, taxonomy_is_cites_eu, rank_name, show_in_trade_ac);

    RAISE INFO 'Swapping concepts materialized view';
    DROP table IF EXISTS taxon_concepts_mview CASCADE;
    ALTER TABLE taxon_concepts_mview_tmp RENAME TO taxon_concepts_mview;
    DROP view IF EXISTS taxon_concepts_view CASCADE;
    ALTER TABLE taxon_concepts_view_tmp RENAME TO taxon_concepts_view;
  END;
  $$;

COMMENT ON FUNCTION rebuild_taxon_concepts_mview() IS 'Procedure to rebuild taxon concepts materialized view in the database.';
