DROP VIEW IF EXISTS taxon_concepts_names_view;
CREATE VIEW taxon_concepts_names_view AS
SELECT
  taxon_concepts.id,
  legacy_id,
  data->'kingdom_name' AS kingdom_name,
  data->'phylum_name' AS phylum_name,
  data->'class_name' AS class_name,
  data->'order_name' AS order_name,
  data->'family_name' AS family_name,
  data->'genus_name' AS genus_name,
  data->'species_name' AS species_name,
  full_name,
  author_year,
  data->'rank_name' AS rank_name,
  name_status,
  taxonomic_position,
  taxonomy_id,
  taxonomies.name AS taxonomy_name,
  ARRAY_TO_STRING(
    ARRAY[
      internal_general_note,
      internal_nomenclature_note,
      internal_distribution_note
    ],
    E'\n'
  ) AS internal_notes,
  to_char(taxon_concepts.created_at, 'DD/MM/YYYY') AS created_at,
  uc.name AS created_by,
  to_char(taxon_concepts.updated_at, 'DD/MM/YYYY') AS updated_at,
  uu.name AS updated_by
FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
LEFT JOIN users uc ON taxon_concepts.created_by_id = uc.id
LEFT JOIN users uu ON taxon_concepts.updated_by_id = uu.id;
