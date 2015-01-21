SELECT
  shipments.*,
  taxon_concepts.full_name AS taxon_concept_full_name,
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
  (taxon_concepts.data->'species_id')::INT AS taxon_concept_species_id,
  (taxon_concepts.data->'class_name') AS taxon_concept_class_name,
  (taxon_concepts.data->'order_name') AS taxon_concept_order_name,
  (taxon_concepts.data->'family_name') AS taxon_concept_family_name,
  (taxon_concepts.data->'genus_name') AS taxon_concept_genus_name,
  reported_taxon_concepts.full_name AS reported_taxon_concept_full_name,
  reported_taxon_concepts.author_year AS reported_taxon_concept_author_year,
  reported_taxon_concepts.name_status AS reported_taxon_concept_name_status,
  reported_taxon_concepts.rank_id AS reported_taxon_concept_rank_id,
  (reported_taxon_concepts.data->'kingdom_id')::INT AS reported_taxon_concept_kingdom_id,
  (reported_taxon_concepts.data->'phylum_id')::INT AS reported_taxon_concept_phylum_id,
  (reported_taxon_concepts.data->'class_id')::INT AS reported_taxon_concept_class_id,
  (reported_taxon_concepts.data->'order_id')::INT AS reported_taxon_concept_order_id,
  (reported_taxon_concepts.data->'family_id')::INT AS reported_taxon_concept_family_id,
  (reported_taxon_concepts.data->'subfamily_id')::INT AS reported_taxon_concept_subfamily_id,
  (reported_taxon_concepts.data->'genus_id')::INT AS reported_taxon_concept_genus_id,
  (reported_taxon_concepts.data->'species_id')::INT AS reported_taxon_concept_species_id
FROM trade_shipments shipments
JOIN taxon_concepts
  ON taxon_concept_id = taxon_concepts.id
LEFT JOIN taxon_concepts reported_taxon_concepts
  ON reported_taxon_concept_id = reported_taxon_concepts.id;
