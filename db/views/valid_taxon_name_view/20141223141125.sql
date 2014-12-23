SELECT full_name AS taxon_name FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
WHERE taxonomies.name = 'CITES_EU';
