DROP VIEW IF EXISTS valid_taxon_concept_term_view;
CREATE VIEW valid_taxon_concept_term_view AS
WITH RECURSIVE self_and_descendants(original_id, id, species_name, term_code) AS (
  SELECT taxon_concepts.id AS original_id, taxon_concepts.id, full_name, terms.code FROM taxon_concepts
  INNER JOIN trade_taxon_concept_code_pairs 
    ON trade_taxon_concept_code_pairs.taxon_concept_id = taxon_concepts.id
  INNER JOIN trade_codes AS terms
    ON terms.id = trade_taxon_concept_code_pairs.trade_code_id
    AND trade_taxon_concept_code_pairs.trade_code_type = 'Term'

  UNION

  SELECT d.original_id, hi.id, hi.full_name, terms.code FROM taxon_concepts hi
  JOIN self_and_descendants d ON d.id = hi.parent_id
  JOIN trade_taxon_concept_code_pairs td ON td.taxon_concept_id =  d.original_id
  JOIN trade_codes AS terms
    ON terms.id = td.trade_code_id
    AND td.trade_code_type = 'Term'
)
SELECT species_name, term_code FROM self_and_descendants
