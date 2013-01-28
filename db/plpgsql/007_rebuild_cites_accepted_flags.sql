--
-- Name: rebuild_cites_accepted_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_cites_accepted_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

        -- set the cites_accepted flag to null for all taxa (so we start clear)
        UPDATE taxon_concepts SET data =
          CASE
            WHEN data IS NULL THEN ''::HSTORE
            ELSE data
          END || hstore('cites_accepted', NULL);

        -- set the cites_accepted flag to true for all explicitly referenced taxa
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', 't')
        FROM (
          SELECT taxon_concepts.id
          FROM taxon_concepts
          INNER JOIN taxon_concept_references
            ON taxon_concept_references.taxon_concept_id = taxon_concepts.id
          INNER JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
          WHERE taxonomies.name = 'WILDLIFE_TRADE' AND (taxon_concept_references.data->'usr_is_std_ref')::BOOLEAN = 't'
        ) AS q
        WHERE taxon_concepts.id = q.id;

        -- set the cites_accepted flag to false for all synonyms
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', 'f')
        FROM (
          SELECT taxon_relationships.other_taxon_concept_id AS id
          FROM taxon_relationships
          INNER JOIN taxon_relationship_types
            ON taxon_relationship_types.id =
              taxon_relationships.taxon_relationship_type_id
          INNER JOIN taxon_concepts
            ON taxon_concepts.id = taxon_relationships.other_taxon_concept_id
          INNER JOIN taxonomies
            ON taxonomies.id = taxon_concepts.taxonomy_id
          WHERE taxonomies.name = 'WILDLIFE_TRADE'
            AND taxon_relationship_types.name = 'HAS_SYNONYM'
        ) AS q
        WHERE taxon_concepts.id = q.id;

        -- set the usr_no_std_ref for exclusions
        UPDATE taxon_concepts
        SET data = data || hstore('usr_no_std_ref', 't')
        FROM (
          WITH RECURSIVE cascading_refs AS (
            SELECT h, h.id, (taxon_concept_references.data->'exclusions')::INTEGER[] AS exclusions, false AS i_am_excluded
            FROM taxon_concept_references
            INNER JOIN taxon_concepts h
              ON h.id = taxon_concept_references.taxon_concept_id
            WHERE (taxon_concept_references.data->'cascade')::BOOLEAN
  
            UNION ALL
  
            SELECT hi, hi.id, exclusions, exclusions @> ARRAY[hi.id]
            FROM cascading_refs
            JOIN taxon_concepts hi
            ON hi.parent_id = (cascading_refs.h).id
          )
          SELECT id, BOOL_AND(i_am_excluded) AS i_am_excluded --excluded from all parent refs
          FROM cascading_refs
          GROUP BY id
        ) AS q
        WHERE taxon_concepts.id = q.id AND i_am_excluded;

        -- set the cites_accepted flag to true for all implicitly referenced taxa
        WITH RECURSIVE q AS
        (
          SELECT  h,
            CASE
              WHEN (h.data->'usr_no_std_ref')::BOOLEAN = 't' THEN 'f'
              ELSE (h.data->'cites_accepted')::BOOLEAN
            END AS inherited_cites_accepted
          FROM taxon_concept_references
          INNER JOIN taxon_concepts h
            ON h.id = taxon_concept_references.taxon_concept_id
          WHERE (taxon_concept_references.data->'cascade')::BOOLEAN

          UNION ALL

          SELECT  hi,
          CASE
            WHEN (data->'cites_accepted')::BOOLEAN = 't' THEN 't'
            WHEN (data->'usr_no_std_ref')::BOOLEAN = 't' THEN 'f'
            ELSE inherited_cites_accepted
          END
          FROM    q
          JOIN    taxon_concepts hi
          ON      hi.parent_id = (q.h).id
        )
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', (q.inherited_cites_accepted)::VARCHAR)
        FROM q
        WHERE taxon_concepts.id = (q.h).id AND
          ((q.h).data->'cites_accepted')::BOOLEAN IS NULL;

        -- set the cites_accepted flag to false where it is not set
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', 'f')
        WHERE (data->'cites_accepted')::BOOLEAN IS NULL;

        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_accepted_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_accepted_flags() IS 'Procedure to rebuild the cites_accepted flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - CITES accepted name, "f" - not accepted, but shows in Checklist, null - not accepted, doesn''t show';