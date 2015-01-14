CREATE OR REPLACE FUNCTION rebuild_cms_species_listing_mview() RETURNS VOID
  LANGUAGE plpgsql
  AS $$
  BEGIN

  DROP TABLE IF EXISTS cms_species_listing_mview_tmp;

CREATE TABLE cms_species_listing_mview_tmp AS
SELECT
  taxon_concepts_mview.id AS id,
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.kingdom_id AS kingdom_id,
  taxon_concepts_mview.phylum_id AS phylum_id,
  taxon_concepts_mview.class_id AS class_id,
  taxon_concepts_mview.order_id AS order_id,
  taxon_concepts_mview.family_id AS family_id,
  taxon_concepts_mview.genus_id AS genus_id,
  taxon_concepts_mview.phylum_name AS phylum_name,
  taxon_concepts_mview.class_name AS class_name,
  taxon_concepts_mview.order_name AS order_name,
  taxon_concepts_mview.family_name AS family_name,
  taxon_concepts_mview.genus_name AS genus_name,
  taxon_concepts_mview.full_name AS full_name,
  taxon_concepts_mview.author_year AS author_year,
  taxon_concepts_mview.rank_name AS rank_name,
  'CMS' AS agreement,
  taxon_concepts_mview.cms_listed,
  taxon_concepts_mview.cms_listing_original AS cms_listing_original,
  ARRAY_TO_STRING(
    ARRAY_AGG(DISTINCT full_name_with_spp(original_taxon_concepts_mview.rank_name, original_taxon_concepts_mview.full_name)),
    ','
  ) AS original_taxon_concept_full_name_with_spp,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || listing_changes_mview.species_listing_name || '** '
      || to_char(listing_changes_mview.effective_at, 'DD/MM/YYYY')
      ORDER BY listing_changes_mview.species_listing_name
    ),
    E'\n'
  ) AS original_taxon_concept_effective_at,
  ARRAY_TO_STRING(
    ARRAY_AGG(
      '**' || listing_changes_mview.species_listing_name || '** '
      || CASE 
      WHEN LENGTH(listing_changes_mview.auto_note_en) > 0 THEN '[' || listing_changes_mview.auto_note_en || '] ' 
      ELSE '' 
      END 
      || CASE 
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
JOIN cms_listing_changes_mview listing_changes_mview
   ON listing_changes_mview.taxon_concept_id = taxon_concepts_mview.id
   AND is_current
   AND change_type_name = 'ADDITION'
JOIN taxon_concepts_mview original_taxon_concepts_mview
   ON listing_changes_mview.original_taxon_concept_id = original_taxon_concepts_mview.id
LEFT JOIN taxon_concepts_mview inclusion_taxon_concepts_mview
   ON listing_changes_mview.inclusion_taxon_concept_id = inclusion_taxon_concepts_mview.id 
WHERE "taxon_concepts_mview"."name_status" = 'A'
   AND "taxon_concepts_mview"."taxonomy_is_cites_eu" = FALSE 
   AND "taxon_concepts_mview"."cms_show" = 't' 
   AND "taxon_concepts_mview"."rank_name" IN ('SPECIES', 'SUBSPECIES', 'VARIETY') 
   AND (taxon_concepts_mview.cms_listing_original != 'NC') 
GROUP BY 
  taxon_concepts_mview.id,
  taxon_concepts_mview.kingdom_id,
  taxon_concepts_mview.phylum_id,
  taxon_concepts_mview.class_id,
  taxon_concepts_mview.order_id,
  taxon_concepts_mview.family_id,
  taxon_concepts_mview.genus_id,
  taxon_concepts_mview.phylum_name,
  taxon_concepts_mview.class_name,
  taxon_concepts_mview.order_name,
  taxon_concepts_mview.family_name,
  taxon_concepts_mview.genus_name,
  taxon_concepts_mview.full_name,
  taxon_concepts_mview.author_year,
  taxon_concepts_mview.rank_name,
  taxon_concepts_mview.cms_listed,
  taxon_concepts_mview.cms_listing_original,
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
  taxon_concepts_mview.uncertain_distribution_ary_en

UNION

SELECT
  taxon_concepts_mview.id AS id,
  taxon_concepts_mview.taxonomic_position,
  taxon_concepts_mview.kingdom_id AS kingdom_id,
  taxon_concepts_mview.phylum_id AS phylum_id,
  taxon_concepts_mview.class_id AS class_id,
  taxon_concepts_mview.order_id AS order_id,
  taxon_concepts_mview.family_id AS family_id,
  taxon_concepts_mview.genus_id,
  taxon_concepts_mview.phylum_name AS phylum_name,
  taxon_concepts_mview.class_name AS class_name,
  taxon_concepts_mview.order_name AS order_name,
  taxon_concepts_mview.family_name AS family_name,
  taxon_concepts_mview.genus_name AS genus_name,
  taxon_concepts_mview.full_name AS full_name,
  taxon_concepts_mview.author_year AS author_year,
  taxon_concepts_mview.rank_name AS rank_name,
  instruments.name AS agreement,
  NULL,
  '',
  '',
  to_char(taxon_instruments.effective_from, 'DD/MM/YYYY') AS effective_at,
  '',
  '{}'::INT[],
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
 FROM taxon_instruments
 JOIN taxon_concepts_mview
   ON taxon_instruments.taxon_concept_id = taxon_concepts_mview.id
 JOIN instruments
   ON taxon_instruments.instrument_id = instruments.id;

  CREATE INDEX ON cms_species_listing_mview_tmp USING GIN (countries_ids_ary); -- search by geo entity

  DROP TABLE IF EXISTS cms_species_listing_mview;
  ALTER TABLE cms_species_listing_mview_tmp RENAME TO cms_species_listing_mview;

END;
$$;