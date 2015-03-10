CREATE VIEW missing_exclusion_lcs AS
WITH parent_lcs AS (
  SELECT * FROM listing_changes
  WHERE event_id = 76
), exclusion_lcs AS (
  SELECT listing_changes.*
  FROM listing_changes
  JOIN parent_lcs
  ON parent_lcs.id = listing_changes.parent_id
)
SELECT
  exclusion_lcs.taxon_concept_id,
  exclusion_lcs.species_listing_id,
  exclusion_lcs.change_type_id,
  copied_parents.effective_at,
  copied_parents.is_current,
  copied_parents.id AS parent_id,
  exclusion_lcs.id As original_id,
  exclusion_lcs.explicit_change,
  copied_parents.created_at,
  copied_parents.updated_at,
  copied_parents.created_by_id,
  copied_parents.updated_by_id
FROM exclusion_lcs
JOIN listing_changes copied_parents
  ON copied_parents.original_id = exclusion_lcs.parent_id
LEFT JOIN listing_changes copied_exclusion_lcs
  ON exclusion_lcs.id = copied_exclusion_lcs.original_id
WHERE copied_exclusion_lcs.id IS NULL;
﻿
INSERT INTO listing_changes (
  taxon_concept_id,
  species_listing_id,
  change_type_id,
  effective_at,
  is_current,
  parent_id,
  original_id,
  explicit_change,
  created_at,
  updated_at,
  created_by_id,
  updated_by_id
)
SELECT * FROM missing_exclusion_lcs;


CREATE VIEW missing_exclusion_distrs AS
WITH parent_lcs AS (
  SELECT * FROM listing_changes
  WHERE event_id = 76
), exclusion_lcs AS (
  SELECT listing_changes.*
  FROM listing_changes
  JOIN parent_lcs
  ON parent_lcs.id = listing_changes.parent_id
), copied_exclusion_lcs AS (
  SELECT listing_changes.*
  FROM listing_changes
  JOIN exclusion_lcs
  ON exclusion_lcs.id = listing_changes.original_id
), exclusion_distrs AS (
  SELECT listing_distributions.*
  FROM listing_distributions
  JOIN exclusion_lcs ON listing_distributions.listing_change_id = exclusion_lcs.id
)
  SELECT
    copied_exclusion_lcs.id AS listing_change_id,
    exclusion_distrs.geo_entity_id,
    exclusion_distrs.is_party,
    exclusion_distrs.id AS original_id,
    copied_exclusion_lcs.created_at,
    copied_exclusion_lcs.updated_at,
    copied_exclusion_lcs.created_by_id,
    copied_exclusion_lcs.updated_by_id
  FROM exclusion_distrs
  JOIN copied_exclusion_lcs
  ON copied_exclusion_lcs.original_id = exclusion_distrs.listing_change_id
  LEFT JOIN listing_distributions copied_exclusion_distrs
  ON exclusion_distrs.id = copied_exclusion_distrs.original_id
  WHERE copied_exclusion_distrs.id IS NULL;

INSERT INTO listing_distributions (
  listing_change_id,
  geo_entity_id,
  is_party,
  original_id,
  created_at,
  updated_at,
  created_by_id,
  updated_by_id
)
SELECT * FROM missing_exclusion_distrs;

DROP VIEW missing_exclusion_lcs;
DROP VIEW missing_exclusion_distrs;

  








