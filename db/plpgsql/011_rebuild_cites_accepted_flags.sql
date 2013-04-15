CREATE OR REPLACE FUNCTION rebuild_cites_accepted_flags_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      cites_eu_id int;
      ancestor_node_id int;
    BEGIN
    SELECT id INTO cites_eu_id FROM taxonomies WHERE name = 'CITES_EU';
    -- set the cites_accepted flag to null for all taxa (so we start clear)
    UPDATE taxon_concepts SET data =
      CASE
        WHEN data IS NULL THEN ''::HSTORE
        ELSE data
      END || hstore('cites_accepted', NULL)
    WHERE taxonomy_id = cites_eu_id AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    -- set the cites_accepted flag to true for all explicitly referenced taxa
    UPDATE taxon_concepts
    SET data = data || hstore('cites_accepted', 't')
    FROM (
      SELECT taxon_concepts.id
      FROM taxon_concepts
      INNER JOIN taxon_concept_references
        ON taxon_concept_references.taxon_concept_id = taxon_concepts.id
      INNER JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
        AND taxonomies.name = 'CITES_EU'
      WHERE
        taxon_concept_references.is_standard = TRUE
        AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END
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
        AND taxonomies.name = 'CITES_EU'
      WHERE
        taxon_relationship_types.name = 'HAS_SYNONYM'
        AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END
    ) AS q
    WHERE taxon_concepts.id = q.id;

    -- set the usr_no_std_ref for exclusions
    UPDATE taxon_concepts
    SET data = data || hstore('usr_no_std_ref', 't')
    FROM (
      WITH RECURSIVE cascading_refs AS (
        SELECT h.id, h.parent_id, taxon_concept_references.excluded_taxon_concepts_ids exclusions, false AS i_am_excluded
        FROM taxon_concept_references
        INNER JOIN taxon_concepts h
          ON h.id = taxon_concept_references.taxon_concept_id
        WHERE taxon_concept_references.is_cascaded AND
        CASE WHEN node_id IS NOT NULL THEN h.id = node_id ELSE TRUE END

        UNION

        SELECT hi.id, hi.parent_id, exclusions, exclusions @> ARRAY[hi.id]
        FROM cascading_refs
        JOIN taxon_concepts hi
        ON hi.parent_id = cascading_refs.id
      )
      SELECT id, BOOL_AND(i_am_excluded) AS i_am_excluded --excluded from all parent refs
      FROM cascading_refs
      GROUP BY id
    ) AS q
    WHERE taxon_concepts.id = q.id AND i_am_excluded;

    IF node_id IS NOT NULL THEN
      WITH RECURSIVE ancestors AS (
        SELECT h.id, h.parent_id, h_ref.is_standard AS is_std_ref,
          h_ref.is_cascaded AS cascade
        FROM taxon_concepts h
        LEFT JOIN taxon_concept_references h_ref
          ON h_ref.taxon_concept_id = h.id
        WHERE h.id = node_id

        UNION

        SELECT hi.id, hi.parent_id, hi_ref.is_standard,
          hi_ref.is_cascaded
        FROM taxon_concepts hi JOIN ancestors ON hi.id = ancestors.parent_id
        LEFT JOIN taxon_concept_references hi_ref
          ON hi_ref.taxon_concept_id = hi.id
      )
      SELECT id INTO ancestor_node_id
      FROM ancestors
      WHERE is_std_ref AND cascade
      LIMIT 1;
    END IF;

    -- set the cites_accepted flag to true for all implicitly referenced taxa
    WITH RECURSIVE q AS
    (
      SELECT  h.id, h.parent_id, h.data,
        CASE
          WHEN (h.data->'usr_no_std_ref')::BOOLEAN = 't' THEN 'f'
          ELSE (h.data->'cites_accepted')::BOOLEAN
        END AS inherited_cites_accepted
      FROM taxon_concept_references
      INNER JOIN taxon_concepts h
        ON h.id = taxon_concept_references.taxon_concept_id
      WHERE taxon_concept_references.is_cascaded AND
      CASE WHEN ancestor_node_id IS NOT NULL THEN h.id = ancestor_node_id ELSE TRUE END

      UNION

      SELECT  hi.id, hi.parent_id, hi.data,
      CASE
        WHEN (hi.data->'cites_accepted')::BOOLEAN = 't' THEN 't'
        WHEN (hi.data->'usr_no_std_ref')::BOOLEAN = 't' THEN 'f'
        ELSE inherited_cites_accepted
      END
      FROM    q
      JOIN    taxon_concepts hi
      ON      hi.parent_id = q.id
    )
    UPDATE taxon_concepts
    SET data = taxon_concepts.data || hstore('cites_accepted', (q.inherited_cites_accepted)::VARCHAR)
    FROM q
    WHERE taxon_concepts.id = q.id;

    -- set the cites_accepted flag to false where it is not set
    UPDATE taxon_concepts
    SET data = taxon_concepts.data || hstore('cites_accepted', 'f')
    WHERE (taxon_concepts.data->'cites_accepted')::BOOLEAN IS NULL AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cites_accepted_flags() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_cites_accepted_flags_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_cites_accepted_flags() IS 'Procedure to rebuild the cites_accepted flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - CITES accepted name, "f" - not accepted, but shows in Checklist, null - not accepted, doesn''t show';
