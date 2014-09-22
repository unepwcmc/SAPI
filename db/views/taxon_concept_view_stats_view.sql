  DROP VIEW IF EXISTS taxon_concept_view_stats_view;

  CREATE VIEW taxon_concept_view_stats_view AS
  SELECT 
    properties->>'id' AS id,
    properties->>'full_name' AS species,
    properties->>'taxonomy_name' AS taxonomy,
    COUNT(*) AS number_of_visits
  FROM ahoy_events
  WHERE name = 'Taxon Concept'
  GROUP BY properties->>'id', properties->>'full_name', properties->>'taxonomy_name';
