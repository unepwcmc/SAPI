DROP VIEW IF EXISTS trade_shipments_with_taxa_view;
CREATE VIEW trade_shipments_with_taxa_view AS
  SELECT
    shipments.*,
    taxon_concepts.full_name AS taxon_concept_full_name,
    (taxon_concepts.data->'kingdom_id')::INT AS taxon_concept_kingdom_id,
    (taxon_concepts.data->'phylum_id')::INT AS taxon_concept_phylum_id,
    (taxon_concepts.data->'class_id')::INT AS taxon_concept_class_id,
    (taxon_concepts.data->'order_id')::INT AS taxon_concept_order_id,
    (taxon_concepts.data->'family_id')::INT AS taxon_concept_family_id,
    (taxon_concepts.data->'subfamily_id')::INT AS taxon_concept_subfamily_id,
    (taxon_concepts.data->'genus_id')::INT AS taxon_concept_genus_id,
    (taxon_concepts.data->'species_id')::INT AS taxon_concept_species_id,
    reported_taxon_concepts.full_name AS reported_taxon_concept_full_name,
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
