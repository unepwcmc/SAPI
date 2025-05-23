CREATE OR REPLACE FUNCTION rebuild_cites_species_listing_mview() RETURNS VOID
  LANGUAGE plpgsql
  AS $$
  BEGIN

  DROP TABLE IF EXISTS cites_species_listing_mview_tmp;

CREATE TABLE cites_species_listing_mview_tmp AS
SELECT
  taxon_concepts_mview.id AS id,
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.kingdom_id AS kingdom_id,
  taxon_concepts_mview.phylum_id AS phylum_id,
  taxon_concepts_mview.class_id AS class_id,
  taxon_concepts_mview.order_id AS order_id,
  taxon_concepts_mview.family_id AS family_id,
  taxon_concepts_mview.genus_id AS genus_id,
  taxon_concepts_mview.kingdom_name AS kingdom_name,
  taxon_concepts_mview.phylum_name AS phylum_name,
  taxon_concepts_mview.class_name AS class_name,
  taxon_concepts_mview.order_name AS order_name,
  taxon_concepts_mview.family_name AS family_name,
  taxon_concepts_mview.genus_name AS genus_name,
  taxon_concepts_mview.species_name AS species_name,
  taxon_concepts_mview.subspecies_name AS subspecies_name,
  taxon_concepts_mview.full_name AS full_name,
  taxon_concepts_mview.author_year AS author_year,
  taxon_concepts_mview.rank_name AS rank_name,
  taxon_concepts_mview.cites_listed,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0
    OR taxon_concepts_mview.cites_listing_original = 'NC'
    THEN TRUE
    ELSE FALSE
  END AS cites_nc,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0
    THEN 'NC'
    ELSE taxon_concepts_mview.cites_listing_original
  END AS cites_listing_original,
  ARRAY_TO_STRING(
    ARRAY_AGG(DISTINCT listing_changes_mview.party_iso_code),
    ','
  ) AS original_taxon_concept_party_iso_code,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      DISTINCT full_name_with_spp(
        COALESCE(inclusion_taxon_concepts_mview.rank_name, original_taxon_concepts_mview.rank_name),
        COALESCE(inclusion_taxon_concepts_mview.full_name, original_taxon_concepts_mview.full_name),
        COALESCE(inclusion_taxon_concepts_mview.name_status, original_taxon_concepts_mview.name_status)
      )
    ),
    ','
  ) AS original_taxon_concept_full_name_with_spp,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || listing_changes_mview.species_listing_name || '** '
      || CASE
        WHEN LENGTH(listing_changes_mview.auto_note_en) > 0 THEN '[' || listing_changes_mview.auto_note_en || '] '
        ELSE ''
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.inherited_full_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_full_note_en)
        WHEN LENGTH(listing_changes_mview.inherited_short_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_short_note_en)
        WHEN LENGTH(listing_changes_mview.full_note_en) > 0 THEN strip_tags(listing_changes_mview.full_note_en)
        ELSE strip_tags(listing_changes_mview.short_note_en)
      END
      || CASE
          WHEN LENGTH(listing_changes_mview.nomenclature_note_en) > 0 THEN strip_tags(listing_changes_mview.nomenclature_note_en)
          ELSE ''
      END
      ORDER BY listing_changes_mview.species_listing_name
    ),
    E'\n'
  ) AS original_taxon_concept_full_note_en,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || species_listing_name || '** ' || listing_changes_mview.hash_ann_symbol || ' '
      || strip_tags(listing_changes_mview.hash_full_note_en)
      ORDER BY species_listing_name
    ),
    E'\n'
  ) AS original_taxon_concept_hash_full_note_en,
  taxon_concepts_mview.countries_ids_ary,
  ARRAY_TO_STRING(taxon_concepts_mview.all_distribution_ary_en, ',') AS all_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.all_distribution_iso_codes_ary, ',') AS all_distribution_iso_codes,
  ARRAY_TO_STRING(taxon_concepts_mview.native_distribution_ary_en, ',') AS native_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.introduced_distribution_ary_en, ',') AS introduced_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.introduced_uncertain_distribution_ary_en, ',') AS introduced_uncertain_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.reintroduced_distribution_ary_en, ',') AS reintroduced_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.extinct_distribution_ary_en, ',') AS extinct_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.extinct_uncertain_distribution_ary_en, ',') AS extinct_uncertain_distribution,
  ARRAY_TO_STRING(taxon_concepts_mview.uncertain_distribution_ary_en, ',') AS uncertain_distribution
FROM "taxon_concepts_mview"
JOIN cites_listing_changes_mview listing_changes_mview
  ON listing_changes_mview.taxon_concept_id = taxon_concepts_mview.id
  AND is_current
  AND change_type_name = 'ADDITION'
JOIN taxon_concepts_mview original_taxon_concepts_mview
  ON listing_changes_mview.original_taxon_concept_id = original_taxon_concepts_mview.id
LEFT JOIN taxon_concepts_mview inclusion_taxon_concepts_mview
  ON listing_changes_mview.inclusion_taxon_concept_id = inclusion_taxon_concepts_mview.id
WHERE "taxon_concepts_mview"."name_status" = 'A'
  AND "taxon_concepts_mview".taxonomy_is_cites_eu = TRUE
  AND "taxon_concepts_mview"."cites_show" = 't'
  AND "taxon_concepts_mview"."rank_name" IN ('SPECIES', 'SUBSPECIES', 'VARIETY')
  AND (taxon_concepts_mview.cites_listing_original != 'NC')
GROUP BY
  taxon_concepts_mview.id,
  taxon_concepts_mview.kingdom_id,
  taxon_concepts_mview.phylum_id,
  taxon_concepts_mview.class_id,
  taxon_concepts_mview.order_id,
  taxon_concepts_mview.family_id,
  taxon_concepts_mview.genus_id,
  taxon_concepts_mview.kingdom_name,
  taxon_concepts_mview.phylum_name,
  taxon_concepts_mview.class_name,
  taxon_concepts_mview.order_name,
  taxon_concepts_mview.family_name,
  taxon_concepts_mview.genus_name,
  taxon_concepts_mview.species_name,
  taxon_concepts_mview.subspecies_name,
  taxon_concepts_mview.full_name,
  taxon_concepts_mview.author_year,
  taxon_concepts_mview.rank_name,
  taxon_concepts_mview.cites_listed,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0
    OR taxon_concepts_mview.cites_listing_original = 'NC'
    THEN TRUE
    ELSE FALSE
  END,
  CASE
    WHEN taxon_concepts_mview.cites_listing_original IS NULL
    OR LENGTH(taxon_concepts_mview.cites_listing_original) = 0
    THEN 'NC' ELSE taxon_concepts_mview.cites_listing_original
  END,
  COALESCE(inclusion_taxon_concepts_mview.full_name, original_taxon_concepts_mview.full_name),
  COALESCE(inclusion_taxon_concepts_mview.spp, original_taxon_concepts_mview.spp),
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.countries_ids_ary,
  taxon_concepts_mview.all_distribution_ary_en,
  taxon_concepts_mview.all_distribution_iso_codes_ary,
  taxon_concepts_mview.native_distribution_ary_en,
  taxon_concepts_mview.introduced_distribution_ary_en,
  taxon_concepts_mview.introduced_uncertain_distribution_ary_en,
  taxon_concepts_mview.reintroduced_distribution_ary_en,
  taxon_concepts_mview.extinct_distribution_ary_en,
  taxon_concepts_mview.extinct_uncertain_distribution_ary_en,
  taxon_concepts_mview.uncertain_distribution_ary_en;

  CREATE INDEX ON cites_species_listing_mview_tmp USING GIN (countries_ids_ary); -- search by geo entity

  DROP TABLE IF EXISTS cites_species_listing_mview;
  ALTER TABLE cites_species_listing_mview_tmp RENAME TO cites_species_listing_mview;

END;
$$;