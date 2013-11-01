DROP VIEW IF EXISTS valid_taxon_concept_term_view;
CREATE VIEW valid_taxon_concept_term_view AS
WITH RECURSIVE self_and_descendants(id, species_name, pair_id) AS (
  SELECT taxon_concepts.id, full_name, trade_taxon_concept_term_pairs.id 
    FROM trade_taxon_concept_term_pairs
    INNER JOIN taxon_concepts
      ON trade_taxon_concept_term_pairs.taxon_concept_id = taxon_concepts.id
    WHERE name_status = 'A'

  UNION

  SELECT hi.id, hi.full_name, d.pair_id FROM taxon_concepts hi
    JOIN self_and_descendants d ON d.id = hi.parent_id
    WHERE name_status = 'A'
)
SELECT species_name, terms.code AS term_code FROM self_and_descendants
INNER JOIN trade_taxon_concept_term_pairs
  ON trade_taxon_concept_term_pairs.id = self_and_descendants.pair_id
INNER JOIN trade_codes AS terms
  ON terms.id = trade_taxon_concept_term_pairs.term_id
  AND terms.type = 'Term'
