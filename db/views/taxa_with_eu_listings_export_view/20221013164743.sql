WITH lc_eu AS (
         SELECT lc.id AS eu_id,
            lc.taxon_concept_id AS eu_taxon_concept_id,
            lc.species_listing_name AS eu_annex,
            lc.party_en AS eu_party_en,
            lc.party_es AS eu_party_es,
            lc.party_fr AS eu_party_fr,
            lc.annotation_en AS eu_annotation_en,
            lc.annotation_es AS eu_annotation_es,
            lc.annotation_fr AS eu_annotation_fr,
            lc.hash_annotation_en AS eu_hash_annotation_en,
            lc.hash_annotation_es AS eu_hash_annotation_es,
            lc.hash_annotation_fr AS eu_hash_annotation_fr,
            lc.effective_at AS eu_effective_at
           FROM api_eu_listing_changes_view lc
          WHERE lc.is_current AND lc.change_type_name::text = 'ADDITION'::text
        ), lc_cites AS (
         SELECT lc.id AS cites_id,
            lc.taxon_concept_id AS cites_taxon_concept_id,
            lc.species_listing_name AS cites_annex,
            lc.party_en AS cites_party_en,
            lc.party_es AS cites_party_es,
            lc.party_fr AS cites_party_fr,
            lc.annotation_en AS cites_annotation_en,
            lc.annotation_es AS cites_annotation_es,
            lc.annotation_fr AS cites_annotation_fr,
            lc.hash_annotation_en AS cites_hash_annotation_en,
            lc.hash_annotation_es AS cites_hash_annotation_es,
           lc.hash_annotation_fr AS cites_hash_annotation_fr,
           lc.effective_at AS cites_effective_at
          FROM api_cites_listing_changes_view lc
         WHERE lc.is_current AND lc.change_type_name::text = 'ADDITION'::text
       )
SELECT tc.id,
   tc.parent_id,
   tc.full_name,
   tc.author_year,
   tc.name_status,
   tc.rank,
   tc.cites_listing,
   tc.kingdom_name,
   tc.phylum_name,
   tc.class_name,
   tc.order_name,
   tc.family_name,
   tc.genus_name,
   tc.kingdom_id,
   tc.phylum_id,
   tc.class_id,
   tc.order_id,
   tc.family_id,
   tc.genus_id,
   tc.created_at,
   tc.updated_at,
   tc.active,
   lc_eu.eu_id,
   lc_eu.eu_taxon_concept_id,
   lc_eu.eu_annex,
   lc_eu.eu_party_en,
   lc_eu.eu_party_es,
   lc_eu.eu_party_fr,
   lc_eu.eu_annotation_en,
   lc_eu.eu_annotation_es,
   lc_eu.eu_annotation_fr,
    lc_eu.eu_hash_annotation_en,
    lc_eu.eu_hash_annotation_es,
    lc_eu.eu_hash_annotation_fr,
    lc_eu.eu_effective_at
   FROM api_taxon_concepts_view tc
     LEFT JOIN lc_eu ON lc_eu.eu_taxon_concept_id = tc.id
  WHERE tc.active AND tc.name_status = 'A'::text AND tc.taxonomy_is_cites_eu AND (tc.rank::text = ANY (ARRAY['SPECIES'::character varying::text, 'SUBSPECIES'::character varying::text, 'VARIETY'::character varying::text]))
  ORDER BY tc.taxonomic_position;
