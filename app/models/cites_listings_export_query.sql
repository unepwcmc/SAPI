SELECT taxon_concepts_mview.id AS id, 
taxon_concepts_mview.kingdom_name AS kingdom_name, taxon_concepts_mview.phylum_name AS phylum_name, taxon_concepts_mview.class_name AS class_name, 
taxon_concepts_mview.order_name AS order_name, taxon_concepts_mview.family_name AS family_name, taxon_concepts_mview.genus_name AS genus_name, 
LOWER(taxon_concepts_mview.species_name) AS species_name, LOWER(taxon_concepts_mview.subspecies_name) AS subspecies_name, 
taxon_concepts_mview.full_name AS full_name, taxon_concepts_mview.author_year AS author_year, 
taxon_concepts_mview.rank_name AS rank_name, 
taxon_concepts_mview.cites_listing_original AS cites_listing_original, 

 ARRAY_TO_STRING(
 ARRAY_AGG(
 DISTINCT lcm.party_iso_code
 ),
 ','
 ) AS cascaded_party_iso_code,

 ARRAY_TO_STRING(
 ARRAY_AGG(
  DISTINCT full_name_with_spp(original_tcm.rank_name, original_tcm.full_name)
 ),
 ','
 ) AS cascaded_full_name_with_spp,

 ARRAY_TO_STRING(
 ARRAY_AGG(
 '**' || lcm.species_listing_name || '** ' || 
 CASE WHEN LENGTH(lcm.auto_note) > 0 THEN '[' || lcm.auto_note || '] ' ELSE '' END 
 || CASE WHEN LENGTH(lcm.full_note_en) > 0 THEN strip_tags(lcm.full_note_en) ELSE strip_tags(lcm.short_note_en) END
 ORDER BY lcm.species_listing_name
 ),
 '
'
 ) AS cobined_note_en,

 
-- ARRAY_TO_STRING(
-- ARRAY_AGG(
-- '**' || listing_changes_mview.species_listing_name || '** ' || strip_tags(listing_changes_mview.short_note_en)
-- ORDER BY listing_changes_mview.species_listing_name
-- ),
--'
--'
-- ) AS closest_listed_ancestor_short_note_en,
-- ARRAY_TO_STRING(
-- ARRAY_AGG(
-- '**' || listing_changes_mview.species_listing_name || '** ' || strip_tags(listing_changes_mview.full_note_en)
-- ORDER BY listing_changes_mview.species_listing_name
-- ),
-- '
--'
-- ) AS closest_listed_ancestor_full_note_en,

 ARRAY_TO_STRING(
 ARRAY_AGG(
 '**' || lcm.species_listing_name || '** ' || strip_tags(lcm.hash_full_note_en)
 ORDER BY lcm.species_listing_name
 ),
 '
'
 ) AS hash_full_note_en--,

-- ARRAY_TO_STRING(
-- ARRAY_AGG(
-- '**' || listing_changes_mview.species_listing_name || '** ' || strip_tags(listing_changes_mview.hash_full_note_en)
-- ORDER BY listing_changes_mview.species_listing_name
-- ),
-- '
--'
-- ) AS closest_listed_ancestor_hash_full_note_en
 FROM "taxon_concepts_mview" 
 --INNER JOIN "taxon_concepts_mview" "cites_closest_listed_ancestors_taxon_concepts_mview" 
 --ON "cites_closest_listed_ancestors_taxon_concepts_mview"."id" = "taxon_concepts_mview"."cites_closest_listed_ancestor_id"
 INNER JOIN "listing_changes_mview" lcm
 ON taxon_concepts_mview.id = lcm.taxon_concept_id 
 AND lcm.is_current = 't' AND lcm.change_type_name = 'ADDITION' AND designation_name = 'CITES' 
 JOIN taxon_concepts_mview original_tcm
 On lcm.original_taxon_concept_id = original_tcm.id
 --INNER JOIN "listing_changes_mview" 
 --ON "listing_changes_mview"."taxon_concept_id" = "cites_closest_listed_ancestors_taxon_concepts_mview"."id" 
 --AND listing_changes_mview.is_current = 't' AND listing_changes_mview.change_type_name = 'ADDITION' AND listing_changes_mview.designation_name = 'CITES' 
 WHERE "taxon_concepts_mview"."name_status" IN ('A', 'H') 
 AND "taxon_concepts_mview"."taxonomy_id" = 1 
 AND "taxon_concepts_mview"."cites_show" = 't' 
 AND "taxon_concepts_mview"."rank_name" IN ('SPECIES', 'SUBSPECIES', 'VARIETY') 
 GROUP BY taxon_concepts_mview.id,taxon_concepts_mview.kingdom_name,taxon_concepts_mview.phylum_name,taxon_concepts_mview.class_name,taxon_concepts_mview.order_name,taxon_concepts_mview.family_name,taxon_concepts_mview.genus_name,LOWER(taxon_concepts_mview.species_name),LOWER(taxon_concepts_mview.subspecies_name),taxon_concepts_mview.full_name,taxon_concepts_mview.author_year,taxon_concepts_mview.rank_name,
 taxon_concepts_mview.cites_listing_original, original_tcm.full_name,
 original_tcm.spp
,taxon_concepts_mview.taxonomic_position ORDER BY taxon_concepts_mview.taxonomic_position LIMIT 100 OFFSET 0


