SELECT
  taxon_concepts.id,
  taxon_concepts.parent_id,
  taxon_concepts.taxonomy_id,
  CASE
    WHEN taxonomies.name = 'CITES_EU' THEN TRUE
    ELSE FALSE
  END AS taxonomy_is_cites_eu,
  full_name::VARCHAR(255),
  name_status::VARCHAR(255),
  rank_id,
  ranks.name::VARCHAR(255) AS rank_name,
  ranks.display_name_en::VARCHAR(255) AS rank_display_name_en,
  ranks.display_name_es::VARCHAR(255) AS rank_display_name_es,
  ranks.display_name_fr::VARCHAR(255) AS rank_display_name_fr,
  (data->'spp')::BOOLEAN AS spp,
  (data->'cites_accepted')::BOOLEAN AS cites_accepted,
  CASE
    WHEN data->'kingdom_name' = 'Animalia' THEN 0
    ELSE 1
  END AS kingdom_position,
  taxon_concepts.taxonomic_position::VARCHAR(255),
  (data->'kingdom_name')::VARCHAR(255) AS kingdom_name,
  (data->'phylum_name')::VARCHAR(255) AS phylum_name,
  (data->'class_name')::VARCHAR(255) AS class_name,
  (data->'order_name')::VARCHAR(255) AS order_name,
  (data->'family_name')::VARCHAR(255) AS family_name,
  (data->'subfamily_name')::VARCHAR(255) AS subfamily_name,
  (data->'genus_name')::VARCHAR(255) AS genus_name,
  (LOWER(data->'species_name'))::VARCHAR(255) AS species_name,
  (LOWER(data->'subspecies_name'))::VARCHAR(255) AS subspecies_name,
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
  (listing->'cites_status')::VARCHAR(255) AS cites_status,
  (listing->'cites_listing_original')::VARCHAR(255) AS cites_listing_original, --used in CSV downloads
  (listing->'cites_listing')::VARCHAR(255) AS cites_listing,
  (listing->'cites_listing_updated_at')::TIMESTAMP AS cites_listing_updated_at,
  (listing->'ann_symbol')::VARCHAR(255) AS ann_symbol,
  (listing->'hash_ann_symbol')::VARCHAR(255) AS hash_ann_symbol,
  (listing->'hash_ann_parent_symbol')::VARCHAR(255) AS hash_ann_parent_symbol,
  CASE
    WHEN listing->'eu_status' = 'LISTED' AND listing->'eu_level_of_listing' = 't'
    THEN TRUE
    WHEN listing->'eu_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
  END AS eu_listed,
  (listing->'eu_show')::BOOLEAN AS eu_show,
  (listing->'eu_status')::VARCHAR(255) AS eu_status,
  (listing->'eu_listing_original')::VARCHAR(255) AS eu_listing_original,
  (listing->'eu_listing')::VARCHAR(255) AS eu_listing,
  (listing->'eu_listing_updated_at')::TIMESTAMP AS eu_listing_updated_at,
  CASE
    WHEN listing->'cms_status' = 'LISTED' AND listing->'cms_level_of_listing' = 't'
    THEN TRUE
    WHEN listing->'cms_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
  END AS cms_listed,
  (listing->'cms_show')::BOOLEAN AS cms_show,
  (listing->'cms_status')::VARCHAR(255) AS cms_status,
  (listing->'cms_listing_original')::VARCHAR(255) AS cms_listing_original,
  (listing->'cms_listing')::VARCHAR(255) AS cms_listing,
  (listing->'cms_listing_updated_at')::TIMESTAMP AS cms_listing_updated_at,
  (listing->'species_listings_ids')::INT[] AS species_listings_ids,
  (listing->'species_listings_ids_aggregated')::INT[] AS species_listings_ids_aggregated,
  author_year::VARCHAR(255),
  taxon_concepts.created_at,
  taxon_concepts.updated_at,
  taxon_concepts.dependents_updated_at,
  common_names.*,
  synonyms.*,
  countries_ids_ary,
  all_distribution_iso_codes_ary,
  all_distribution_ary_en,
  native_distribution_ary_en,
  introduced_distribution_ary_en,
  introduced_uncertain_distribution_ary_en,
  reintroduced_distribution_ary_en,
  extinct_distribution_ary_en,
  extinct_uncertain_distribution_ary_en,
  uncertain_distribution_ary_en,
  all_distribution_ary_es,
  native_distribution_ary_es,
  introduced_distribution_ary_es,
  introduced_uncertain_distribution_ary_es,
  reintroduced_distribution_ary_es,
  extinct_distribution_ary_es,
  extinct_uncertain_distribution_ary_es,
  uncertain_distribution_ary_es,
  all_distribution_ary_fr,
  native_distribution_ary_fr,
  introduced_distribution_ary_fr,
  introduced_uncertain_distribution_ary_fr,
  reintroduced_distribution_ary_fr,
  extinct_distribution_ary_fr,
  extinct_uncertain_distribution_ary_fr,
  uncertain_distribution_ary_fr,
  CASE
    WHEN
    name_status = 'A'
    AND (
      ranks.name = 'SPECIES'
      OR (
        ranks.name = 'SUBSPECIES'
        AND (
          taxonomies.name = 'CITES_EU'
          AND (
            (listing->'cites_historically_listed')::BOOLEAN
            OR (listing->'eu_historically_listed')::BOOLEAN
          )
          OR
          taxonomies.name = 'CMS'
          AND (listing->'cms_historically_listed')::BOOLEAN
        )
      )
    )
    THEN TRUE
    ELSE FALSE
  END AS show_in_species_plus
FROM taxon_concepts
JOIN ranks ON ranks.id = rank_id
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
LEFT JOIN (
  SELECT *
  FROM
  CROSSTAB(
  'SELECT taxon_commons.taxon_concept_id AS taxon_concept_id_com, languages.iso_code1 AS lng,
  ARRAY_AGG_NOTNULL(common_names.name ORDER BY common_names.name) AS common_names_ary
  FROM "taxon_commons"
  INNER JOIN "common_names"
  ON "common_names"."id" = "taxon_commons"."common_name_id"
  INNER JOIN "languages"
  ON "languages"."id" = "common_names"."language_id" AND UPPER(languages.iso_code1) IN (''EN'', ''FR'', ''ES'')
  GROUP BY taxon_commons.taxon_concept_id, languages.iso_code1
  ORDER BY 1,2',
  'SELECT DISTINCT languages.iso_code1 FROM languages WHERE UPPER(languages.iso_code1) IN (''EN'', ''FR'', ''ES'') order by 1'
  ) AS ct(
  taxon_concept_id_com INTEGER,
  english_names_ary VARCHAR[], spanish_names_ary VARCHAR[], french_names_ary VARCHAR[]
  )
) common_names ON taxon_concepts.id = common_names.taxon_concept_id_com
LEFT JOIN (
  SELECT taxon_relationships.taxon_concept_id AS taxon_concept_id_syn,
  ARRAY_AGG_NOTNULL(synonym_tc.full_name) AS synonyms_ary,
  ARRAY_AGG_NOTNULL(synonym_tc.author_year) AS synonyms_author_years_ary
  FROM taxon_relationships
  JOIN "taxon_relationship_types"
  ON "taxon_relationship_types"."id" = "taxon_relationships"."taxon_relationship_type_id"
  AND "taxon_relationship_types"."name" = 'HAS_SYNONYM'
  JOIN taxon_concepts AS synonym_tc
  ON synonym_tc.id = taxon_relationships.other_taxon_concept_id
  GROUP BY taxon_relationships.taxon_concept_id
) synonyms ON taxon_concepts.id = synonyms.taxon_concept_id_syn
LEFT JOIN (
  SELECT distributions.taxon_concept_id AS taxon_concept_id_cnt,
  ARRAY_AGG_NOTNULL(geo_entities.id ORDER BY geo_entities.name_en) AS countries_ids_ary,
  ARRAY_AGG_NOTNULL(geo_entities.iso_code2 ORDER BY geo_entities.name_en) AS all_distribution_iso_codes_ary,
  ARRAY_AGG_NOTNULL(geo_entities.name_en ORDER BY geo_entities.name_en) AS all_distribution_ary_en,
  ARRAY_AGG_NOTNULL(geo_entities.name_en ORDER BY geo_entities.name_es) AS all_distribution_ary_es,
  ARRAY_AGG_NOTNULL(geo_entities.name_en ORDER BY geo_entities.name_fr) AS all_distribution_ary_fr
  FROM distributions
  JOIN geo_entities
  ON distributions.geo_entity_id = geo_entities.id
  JOIN "geo_entity_types"
  ON "geo_entity_types"."id" = "geo_entities"."geo_entity_type_id"
  AND (geo_entity_types.name = 'COUNTRY' OR geo_entity_types.name = 'TERRITORY')
  GROUP BY distributions.taxon_concept_id
) countries_ids ON taxon_concepts.id = countries_ids.taxon_concept_id_cnt
LEFT JOIN (
  SELECT *
  FROM CROSSTAB(
    'SELECT distributions.taxon_concept_id,
      CASE WHEN tags.name IS NULL THEN ''NATIVE'' ELSE UPPER(tags.name) END || ''_'' || lng AS tag,
      ARRAY_AGG_NOTNULL(geo_entities.name ORDER BY geo_entities.name) AS locations_ary
    FROM distributions
    JOIN (
      SELECT geo_entities.id, geo_entities.iso_code2, ''EN'' AS lng, geo_entities.name_en AS name FROM geo_entities
      UNION
      SELECT geo_entities.id, geo_entities.iso_code2, ''ES'' AS lng, geo_entities.name_es AS name FROM geo_entities
      UNION
      SELECT geo_entities.id, geo_entities.iso_code2, ''FR'' AS lng, geo_entities.name_fr AS name FROM geo_entities
    ) geo_entities
      ON geo_entities.id = distributions.geo_entity_id
    LEFT JOIN taggings
      ON taggable_id = distributions.id AND taggable_type = ''Distribution''
    LEFT JOIN tags
      ON tags.id = taggings.tag_id
      AND (
        UPPER(tags.name) IN (
          ''INTRODUCED'', ''INTRODUCED (?)'', ''REINTRODUCED'',
          ''EXTINCT'', ''EXTINCT (?)'', ''DISTRIBUTION UNCERTAIN''
        ) OR tags.name IS NULL
      )
    GROUP BY distributions.taxon_concept_id, tags.name, geo_entities.lng
    ',
    'SELECT * FROM UNNEST(
      ARRAY[
        ''NATIVE_EN'', ''INTRODUCED_EN'', ''INTRODUCED (?)_EN'', ''REINTRODUCED_EN'',
        ''EXTINCT_EN'', ''EXTINCT (?)_EN'', ''DISTRIBUTION UNCERTAIN_EN'',
        ''NATIVE_ES'', ''INTRODUCED_ES'', ''INTRODUCED (?)_ES'', ''REINTRODUCED_ES'',
        ''EXTINCT_ES'', ''EXTINCT (?)_ES'', ''DISTRIBUTION UNCERTAIN_ES'',
        ''NATIVE_FR'', ''INTRODUCED_FR'', ''INTRODUCED (?)_FR'', ''REINTRODUCED_FR'',
        ''EXTINCT_FR'', ''EXTINCT (?)_FR'', ''DISTRIBUTION UNCERTAIN_FR''
      ])'
  ) AS ct(
    taxon_concept_id INTEGER,
    native_distribution_ary_en VARCHAR[],
    introduced_distribution_ary_en VARCHAR[],
    introduced_uncertain_distribution_ary_en VARCHAR[],
    reintroduced_distribution_ary_en VARCHAR[],
    extinct_distribution_ary_en VARCHAR[],
    extinct_uncertain_distribution_ary_en VARCHAR[],
    uncertain_distribution_ary_en VARCHAR[],
    native_distribution_ary_es VARCHAR[],
    introduced_distribution_ary_es VARCHAR[],
    introduced_uncertain_distribution_ary_es VARCHAR[],
    reintroduced_distribution_ary_es VARCHAR[],
    extinct_distribution_ary_es VARCHAR[],
    extinct_uncertain_distribution_ary_es VARCHAR[],
    uncertain_distribution_ary_es VARCHAR[],
    native_distribution_ary_fr VARCHAR[],
    introduced_distribution_ary_fr VARCHAR[],
    introduced_uncertain_distribution_ary_fr VARCHAR[],
    reintroduced_distribution_ary_fr VARCHAR[],
    extinct_distribution_ary_fr VARCHAR[],
    extinct_uncertain_distribution_ary_fr VARCHAR[],
    uncertain_distribution_ary_fr VARCHAR[]
  )
) distributions_by_tag ON taxon_concepts.id = distributions_by_tag.taxon_concept_id;
