DROP VIEW IF EXISTS taxon_concepts_names;
CREATE VIEW taxon_concepts_names AS
SELECT
  id,
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
  name_status
FROM taxon_concepts;