class AddEuListedToTaxonConceptsView < ActiveRecord::Migration
def change
  execute <<-SQL
    DROP VIEW IF EXISTS taxon_concepts_view;
    CREATE OR REPLACE VIEW taxon_concepts_view AS
    SELECT taxon_concepts.id,
    taxon_concepts.parent_id,
    CASE
    WHEN taxonomies.name = 'CITES_EU' THEN TRUE
    ELSE FALSE
    END AS taxonomy_is_cites_eu,
    full_name,
    name_status,
    data->'rank_name' AS rank_name,
    (data->'spp')::BOOLEAN AS spp,
    (data->'cites_accepted')::BOOLEAN AS cites_accepted,
    CASE
    WHEN data->'kingdom_name' = 'Animalia' THEN 0
    ELSE 1
    END AS kingdom_position,
    taxonomic_position,
    data->'kingdom_name' AS kingdom_name,
    data->'phylum_name' AS phylum_name,
    data->'class_name' AS class_name,
    data->'order_name' AS order_name,
    data->'family_name' AS family_name,
    data->'genus_name' AS genus_name,
    data->'species_name' AS species_name,
    data->'subspecies_name' AS subspecies_name,
    (data->'kingdom_id')::INTEGER AS kingdom_id,
    (data->'phylum_id')::INTEGER AS phylum_id,
    (data->'class_id')::INTEGER AS class_id,
    (data->'order_id')::INTEGER AS order_id,
    (data->'family_id')::INTEGER AS family_id,
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
    WHEN listing->'cites_status' = 'LISTED' AND listing->'cites_status_original' = 't'
    THEN TRUE
    WHEN listing->'cites_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
    END AS cites_listed,
    (listing->'cites_show')::BOOLEAN AS cites_show,
    (listing->'cites_status_original')::BOOLEAN AS cites_status_original,
    listing->'cites_status' AS cites_status,
    listing->'cites_listing_original' AS cites_listing_original,
    listing->'cites_listing' AS cites_listing,
    (listing->'cites_closest_listed_ancestor_id')::INT AS cites_closest_listed_ancestor_id,
    (listing->'cites_listing_updated_at')::TIMESTAMP AS cites_listing_updated_at,
    (listing->'ann_symbol') AS ann_symbol,
    (listing->'hash_ann_symbol') AS hash_ann_symbol,
    (listing->'hash_ann_parent_symbol') AS hash_ann_parent_symbol,
    CASE
    WHEN listing->'eu_status' = 'LISTED' AND listing->'eu_status_original' = 't'
    THEN TRUE
    WHEN listing->'eu_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
    END AS eu_listed,
    (listing->'eu_show')::BOOLEAN AS eu_show,
    (listing->'eu_status_original')::BOOLEAN AS eu_status_original,
    listing->'eu_status' AS eu_status,
    listing->'eu_listing_original' AS eu_listing_original,
    listing->'eu_listing' AS eu_listing,
    (listing->'eu_closest_listed_ancestor_id')::INT AS eu_closest_listed_ancestor_id,
    (listing->'eu_listing_updated_at')::TIMESTAMP AS eu_listing_updated_at,
    (listing->'species_listings_ids')::INT[] AS species_listings_ids,
    (listing->'species_listings_ids_aggregated')::INT[] AS species_listings_ids_aggregated,
    author_year,
    taxon_concepts.created_at,
    taxon_concepts.updated_at,
    common_names.*,
    synonyms.*,
    countries_ids_ary
    FROM taxon_concepts
    LEFT JOIN taxonomies
    ON taxonomies.id = taxon_concepts.taxonomy_id
    LEFT JOIN (
    SELECT *
    FROM
    CROSSTAB(
    'SELECT taxon_concepts.id AS taxon_concept_id_com,
    SUBSTRING(languages.name_en FROM 1 FOR 1) AS lng,
    ARRAY_AGG(common_names.name ORDER BY common_names.id) AS common_names_ary
    FROM "taxon_concepts"
    INNER JOIN "taxon_commons"
    ON "taxon_commons"."taxon_concept_id" = "taxon_concepts"."id"
    INNER JOIN "common_names"
    ON "common_names"."id" = "taxon_commons"."common_name_id"
    INNER JOIN "languages"
    ON "languages"."id" = "common_names"."language_id"
    GROUP BY taxon_concepts.id, SUBSTRING(languages.name_en FROM 1 FOR 1)
    ORDER BY 1,2'
    ) AS ct(
    taxon_concept_id_com INTEGER,
    english_names_ary VARCHAR[], french_names_ary VARCHAR[], spanish_names_ary VARCHAR[]
    )
    ) common_names ON taxon_concepts.id = common_names.taxon_concept_id_com
    LEFT JOIN (
    SELECT taxon_concepts.id AS taxon_concept_id_syn,
    ARRAY_AGG(synonym_tc.full_name) AS synonyms_ary,
    ARRAY_AGG(synonym_tc.author_year) AS synonyms_author_years_ary
    FROM taxon_concepts
    LEFT JOIN taxon_relationships
    ON "taxon_relationships"."taxon_concept_id" = "taxon_concepts"."id"
    LEFT JOIN "taxon_relationship_types"
    ON "taxon_relationship_types"."id" = "taxon_relationships"."taxon_relationship_type_id"
    LEFT JOIN taxon_concepts AS synonym_tc
    ON synonym_tc.id = taxon_relationships.other_taxon_concept_id
    GROUP BY taxon_concepts.id
    ) synonyms ON taxon_concepts.id = synonyms.taxon_concept_id_syn
    LEFT JOIN (
    SELECT taxon_concepts.id AS taxon_concept_id_cnt,
    ARRAY_AGG(geo_entities.id ORDER BY geo_entities.name_en) AS countries_ids_ary
    FROM taxon_concepts
    LEFT JOIN distributions
    ON "distributions"."taxon_concept_id" = "taxon_concepts"."id"
    LEFT JOIN geo_entities
    ON distributions.geo_entity_id = geo_entities.id
    LEFT JOIN "geo_entity_types"
    ON "geo_entity_types"."id" = "geo_entities"."geo_entity_type_id"
    AND geo_entity_types.name = 'COUNTRY'
    GROUP BY taxon_concepts.id
    ) countries_ids ON taxon_concepts.id = countries_ids.taxon_concept_id_cnt
  SQL
  Sapi::rebuild_taxon_concepts_mview
  add_index "taxon_concepts_mview", ["cites_closest_listed_ancestor_id"],
    :name => "index_taxon_concepts_mview_on_cites_closest_listed_ancestor_id"
  add_index "taxon_concepts_mview", ["eu_closest_listed_ancestor_id"],
    :name => "index_taxon_concepts_mview_on_eu_closest_listed_ancestor_id"
  end
end
