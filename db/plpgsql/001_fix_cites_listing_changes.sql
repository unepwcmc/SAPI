--
-- Name: fix_cites_listing_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION fix_cites_listing_changes() RETURNS void
    LANGUAGE plpgsql
    AS $$
      BEGIN
      INSERT INTO listing_changes 
      (taxon_concept_id, species_listing_id, change_type_id, effective_at, created_at, updated_at)
      SELECT 
      qq.taxon_concept_id, qq.species_listing_id, (SELECT id FROM change_types WHERE name = 'DELETION' LIMIT 1),
      qq.effective_at - time '00:00:01', NOW(), NOW()
      FROM (
                    WITH q AS (
                        SELECT listing_changes.id AS id, taxon_concept_id, species_listing_id, change_type_id,
                             effective_at, change_types.name AS change_type_name,
                             species_listings.abbreviation AS listing_name,
                             listing_distributions.geo_entity_id AS party_id, geo_entities_ary,
                             ROW_NUMBER() OVER(ORDER BY taxon_concept_id, effective_at) AS row_no
                             FROM
                             listing_changes
                             LEFT JOIN change_types ON change_type_id = change_types.id
                             LEFT JOIN species_listings ON species_listing_id = species_listings.id
                             LEFT JOIN designations ON designations.id = species_listings.designation_id
                             LEFT JOIN listing_distributions ON listing_changes.id = listing_distributions.listing_change_id
                               AND listing_distributions.is_party = 't'
                             LEFT JOIN (
                               SELECT listing_change_id, ARRAY_AGG(geo_entity_id) AS geo_entities_ary
                               FROM listing_distributions
                               WHERE listing_distributions.is_party <> 't'
                               GROUP BY listing_change_id
                             ) listing_distributions_agr ON listing_distributions_agr.listing_change_id = listing_changes.id
                             WHERE change_types.name IN ('ADDITION','DELETION')
                             AND designations.name = 'CITES'
                     )
                     SELECT q1.taxon_concept_id, q1.species_listing_id, q2.effective_at
                     FROM q q1 LEFT JOIN q q2 ON (q1.taxon_concept_id = q2.taxon_concept_id AND q2.row_no = q1.row_no + 1)
                     WHERE q2.taxon_concept_id IS NOT NULL
                     -- only add a deletion record between two additiona records
                     AND q1.change_type_id = q2.change_type_id AND q1.change_type_name = 'ADDITION'
                     -- do not add between consecutive app III additions by different countries
                     AND NOT (q1.listing_name = 'III' AND q2.listing_name = 'III' AND q1.party_id <> q2.party_id)
                     -- do not add between additions entered on the same day
                     AND NOT (q1.effective_at = q2.effective_at)
                     -- do not add between additions to different appendices where the distribution is different
                     AND NOT (
                     --q1.species_listing_id <> q2.species_listing_id
                     --  AND (
                         q1.geo_entities_ary IS NOT NULL AND q2.geo_entities_ary IS NOT NULL
                           AND q1.geo_entities_ary <> q2.geo_entities_ary
                         OR
                         q1.geo_entities_ary IS NULL AND q2.geo_entities_ary IS NOT NULL
                         OR
                         q2.geo_entities_ary IS NULL AND q1.geo_entities_ary IS NOT NULL
                     --  )
                     )
      ) qq;
      END;
      $$;


--
-- Name: FUNCTION fix_cites_listing_changes(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fix_cites_listing_changes() IS 'Procedure to insert deletions between any two additions to appendices for a given taxon_concept.';
