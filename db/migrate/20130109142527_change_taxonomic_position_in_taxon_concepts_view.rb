class ChangeTaxonomicPositionInTaxonConceptsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE taxon_concepts
      SET taxonomic_position = 
      CASE
        WHEN (data->'taxonomic_position')::VARCHAR IS NOT NULL
          THEN data->'taxonomic_position'
        ELSE '0'
      END
    SQL
    execute "UPDATE taxon_concepts SET data = data - ARRAY['taxonomic_position']"
    execute <<-SQL
    DROP VIEW taxon_concepts_view;
    CREATE OR REPLACE VIEW taxon_concepts_view AS
    SELECT taxon_concepts.id,
    taxon_concepts.parent_id,
    CASE
      WHEN designations.name = 'CITES' THEN TRUE
      ELSE FALSE
    END AS designation_is_cites,
    data->'full_name' AS full_name,
    data->'rank_name' AS rank_name,
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
    (data->'cites_name_status')::VARCHAR AS cites_name_status,
    (listing->'cites_fully_covered')::BOOLEAN AS cites_fully_covered,
    CASE
      WHEN listing->'cites_status' = 'LISTED' AND listing->'cites_status_original' = 't'
      THEN TRUE
      WHEN listing->'cites_status' = 'LISTED'
      THEN FALSE
      ELSE NULL
    END AS cites_listed,
    CASE
      WHEN listing->'cites_status' = 'DELETED'
      THEN TRUE
      ELSE FALSE
    END AS cites_deleted,
    CASE
      WHEN listing->'cites_status' = 'EXCLUDED'
      THEN TRUE
      ELSE FALSE
    END AS cites_excluded,
    (listing->'cites_show')::BOOLEAN AS cites_show,
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
    listing->'cites_listing' AS current_listing,
    (listing->'listing_updated_at')::TIMESTAMP AS listing_updated_at,
    (listing->'specific_annotation_symbol') AS specific_annotation_symbol,
    (listing->'generic_annotation_symbol') AS generic_annotation_symbol,
    (listing->'generic_annotation_parent_symbol') AS generic_annotation_parent_symbol,
    author_year,
    taxon_concepts.created_at,
    taxon_concepts.updated_at,
    common_names.*,
    synonyms.*,
    countries_ids_ary,
    standard_references_ids_ary
    FROM taxon_concepts
    LEFT JOIN designations
      ON designations.id = taxon_concepts.designation_id
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
      ARRAY_AGG(synonym_tc.data->'full_name') AS synonyms_ary,
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
      LEFT JOIN taxon_concept_geo_entities
        ON "taxon_concept_geo_entities"."taxon_concept_id" = "taxon_concepts"."id"
      LEFT JOIN geo_entities
        ON taxon_concept_geo_entities.geo_entity_id = geo_entities.id
      LEFT JOIN "geo_entity_types"
        ON "geo_entity_types"."id" = "geo_entities"."geo_entity_type_id"
          AND geo_entity_types.name = '#{GeoEntityType::COUNTRY}'
      GROUP BY taxon_concepts.id
    ) countries_ids ON taxon_concepts.id = countries_ids.taxon_concept_id_cnt
    LEFT JOIN (
      WITH taxa_with_std_refs AS (
        WITH RECURSIVE q AS (
          SELECT h, h.id, ARRAY_AGG(reference_id) AS standard_references_ids_ary
          FROM taxon_concepts h
          LEFT JOIN taxon_concept_references
          ON h.id = taxon_concept_references.taxon_concept_id
            AND taxon_concept_references.data->'usr_is_std_ref' = 't'
          WHERE h.parent_id IS NULL
          GROUP BY h.id

          UNION ALL

          SELECT hi, hi.id,
            CASE
             WHEN (hi.data->'usr_no_std_ref')::BOOLEAN = 't' THEN ARRAY[]::INTEGER[]
              ELSE standard_references_ids_ary || reference_id
            END
          FROM q
          JOIN taxon_concepts hi ON hi.parent_id = (q.h).id
          LEFT JOIN taxon_concept_references
          ON hi.id = taxon_concept_references.taxon_concept_id
            AND taxon_concept_references.data->'usr_is_std_ref' = 't'
        )
        SELECT DISTINCT id, 
        UNNEST(standard_references_ids_ary) AS std_ref_id
        FROM q 
      )
      SELECT id AS taxon_concept_id_sr, ARRAY_AGG(std_ref_id) AS standard_references_ids_ary
      FROM taxa_with_std_refs
      WHERE std_ref_id IS NOT NULL
      GROUP BY id
    ) standard_references_ids ON taxon_concepts.id = standard_references_ids.taxon_concept_id_sr
    SQL
    Sapi::rebuild_taxon_concepts_mview
  end

  def down
    execute "UPDATE taxon_concepts SET data = data || hstore('taxonomic_position', taxonomic_position)"
    execute <<-SQL
    DROP VIEW taxon_concepts_view;
    CREATE OR REPLACE VIEW taxon_concepts_view AS
    SELECT taxon_concepts.id,
    taxon_concepts.parent_id,
    CASE
      WHEN designations.name = 'CITES' THEN TRUE
      ELSE FALSE
    END AS designation_is_cites,
    data->'full_name' AS full_name,
    data->'rank_name' AS rank_name,
    (data->'cites_accepted')::BOOLEAN AS cites_accepted,
    CASE
      WHEN data->'kingdom_name' = 'Animalia' THEN 0
      ELSE 1
    END AS kingdom_position,
    data->'taxonomic_position' AS taxonomic_position,
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
    (data->'cites_name_status')::VARCHAR AS cites_name_status,
    (listing->'cites_fully_covered')::BOOLEAN AS cites_fully_covered,
    CASE
      WHEN listing->'cites_status' = 'LISTED' AND listing->'cites_status_original' = 't'
      THEN TRUE
      WHEN listing->'cites_status' = 'LISTED'
      THEN FALSE
      ELSE NULL
    END AS cites_listed,
    CASE
      WHEN listing->'cites_status' = 'DELETED'
      THEN TRUE
      ELSE FALSE
    END AS cites_deleted,
    CASE
      WHEN listing->'cites_status' = 'EXCLUDED'
      THEN TRUE
      ELSE FALSE
    END AS cites_excluded,
    (listing->'cites_show')::BOOLEAN AS cites_show,
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
    listing->'cites_listing' AS current_listing,
    (listing->'listing_updated_at')::TIMESTAMP AS listing_updated_at,
    (listing->'specific_annotation_symbol') AS specific_annotation_symbol,
    (listing->'generic_annotation_symbol') AS generic_annotation_symbol,
    (listing->'generic_annotation_parent_symbol') AS generic_annotation_parent_symbol,
    author_year,
    taxon_concepts.created_at,
    taxon_concepts.updated_at,
    common_names.*,
    synonyms.*,
    countries_ids_ary,
    standard_references_ids_ary
    FROM taxon_concepts
    LEFT JOIN designations
      ON designations.id = taxon_concepts.designation_id
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
      ARRAY_AGG(synonym_tc.data->'full_name') AS synonyms_ary,
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
      LEFT JOIN taxon_concept_geo_entities
        ON "taxon_concept_geo_entities"."taxon_concept_id" = "taxon_concepts"."id"
      LEFT JOIN geo_entities
        ON taxon_concept_geo_entities.geo_entity_id = geo_entities.id
      LEFT JOIN "geo_entity_types"
        ON "geo_entity_types"."id" = "geo_entities"."geo_entity_type_id"
          AND geo_entity_types.name = '#{GeoEntityType::COUNTRY}'
      GROUP BY taxon_concepts.id
    ) countries_ids ON taxon_concepts.id = countries_ids.taxon_concept_id_cnt
    LEFT JOIN (
      WITH taxa_with_std_refs AS (
        WITH RECURSIVE q AS (
          SELECT h, h.id, ARRAY_AGG(reference_id) AS standard_references_ids_ary
          FROM taxon_concepts h
          LEFT JOIN taxon_concept_references
          ON h.id = taxon_concept_references.taxon_concept_id
            AND taxon_concept_references.data->'usr_is_std_ref' = 't'
          WHERE h.parent_id IS NULL
          GROUP BY h.id

          UNION ALL

          SELECT hi, hi.id,
            CASE
             WHEN (hi.data->'usr_no_std_ref')::BOOLEAN = 't' THEN ARRAY[]::INTEGER[]
              ELSE standard_references_ids_ary || reference_id
            END
          FROM q
          JOIN taxon_concepts hi ON hi.parent_id = (q.h).id
          LEFT JOIN taxon_concept_references
          ON hi.id = taxon_concept_references.taxon_concept_id
            AND taxon_concept_references.data->'usr_is_std_ref' = 't'
        )
        SELECT DISTINCT id, 
        UNNEST(standard_references_ids_ary) AS std_ref_id
        FROM q 
      )
      SELECT id AS taxon_concept_id_sr, ARRAY_AGG(std_ref_id) AS standard_references_ids_ary
      FROM taxa_with_std_refs
      WHERE std_ref_id IS NOT NULL
      GROUP BY id
    ) standard_references_ids ON taxon_concepts.id = standard_references_ids.taxon_concept_id_sr
    SQL
    Sapi::rebuild_taxon_concepts_mview
  end
end
