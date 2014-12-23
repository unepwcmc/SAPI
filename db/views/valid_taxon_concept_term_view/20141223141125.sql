WITH RECURSIVE self_and_descendants(id, pair_id, term_id) AS (
  SELECT taxon_concepts.id,
    trade_taxon_concept_term_pairs.id, trade_taxon_concept_term_pairs.term_id
    FROM trade_taxon_concept_term_pairs
    INNER JOIN taxon_concepts
      ON trade_taxon_concept_term_pairs.taxon_concept_id = taxon_concepts.id
    WHERE name_status = 'A'

  UNION

  SELECT hi.id, d.pair_id, d.term_id FROM taxon_concepts hi
    JOIN self_and_descendants d ON d.id = hi.parent_id
    WHERE name_status = 'A'
), taxa_with_terms AS (
  SELECT self_and_descendants.id AS taxon_concept_id,
    terms.code AS term_code, self_and_descendants.term_id
  FROM self_and_descendants
  INNER JOIN trade_taxon_concept_term_pairs
    ON trade_taxon_concept_term_pairs.id = self_and_descendants.pair_id
  INNER JOIN trade_codes AS terms
    ON terms.id = trade_taxon_concept_term_pairs.term_id
    AND terms.type = 'Term'
), hybrids_with_terms AS (
  SELECT other_taxon_concept_id AS taxon_concept_id,
    term_code, term_id
  FROM taxa_with_terms
  INNER JOIN taxon_relationships rel
  ON rel.taxon_concept_id = taxa_with_terms.taxon_concept_id
  INNER JOIN taxon_relationship_types rel_type
  ON rel.taxon_relationship_type_id = rel_type.id
    AND rel_type.name = 'HAS_HYBRID'
)
SELECT * FROM taxa_with_terms
UNION
SELECT * FROM hybrids_with_terms;
