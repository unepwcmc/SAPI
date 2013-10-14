DROP VIEW IF EXISTS valid_species_name_appendix_year_view;
CREATE VIEW valid_species_name_appendix_year_view AS
SELECT
  full_name AS species_name,
  data->'cites_listing' AS appendix,
  2012 AS year
FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
JOIN ranks 
  ON ranks.id = taxon_concepts.rank_id 
  AND ranks.name IN ('GENUS', 'SPECIES', 'SUBSPECIES', 'VARIETY')
WHERE taxonomies.name = 'CITES_EU';