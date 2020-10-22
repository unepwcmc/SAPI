SELECT
  shipments.*,
  taxon_concepts.author_year AS taxon_concept_author_year,
  taxon_concepts.name_status AS taxon_concept_name_status,
  taxon_concepts.rank_id AS taxon_concept_rank_id,
  (taxon_concepts.data->'kingdom_id')::INT AS taxon_concept_kingdom_id,
  (taxon_concepts.data->'phylum_id')::INT AS taxon_concept_phylum_id,
  (taxon_concepts.data->'class_id')::INT AS taxon_concept_class_id,
  (taxon_concepts.data->'order_id')::INT AS taxon_concept_order_id,
  (taxon_concepts.data->'family_id')::INT AS taxon_concept_family_id,
  (taxon_concepts.data->'subfamily_id')::INT AS taxon_concept_subfamily_id,
  (taxon_concepts.data->'genus_id')::INT AS taxon_concept_genus_id,
  (taxon_concepts.data->'species_id')::INT AS taxon_concept_species_id
FROM trade_plus_static shipments
JOIN taxon_concepts
ON taxon_id = taxon_concepts.id
