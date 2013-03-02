CREATE OR REPLACE FUNCTION apply_children_listing(node_id INTEGER) RETURNS VOID
  LANGUAGE plpgsql
  AS $$
    DECLARE
      tmp HSTORE;
      child_node_id INT;
    BEGIN
      PERFORM id FROM taxon_concepts WHERE parent_id = node_id;
      IF FOUND THEN
        FOR child_node_id IN SELECT id FROM taxon_concepts
          WHERE parent_id = node_id
        LOOP
          PERFORM apply_children_listing(child_node_id);
        END LOOP;

        SELECT INTO tmp
        hstore('cites_I', MAX((listing -> 'cites_I')::VARCHAR)) ||
        hstore('cites_II', MAX((listing -> 'cites_II')::VARCHAR)) ||
        hstore('cites_III', MAX((listing -> 'cites_III')::VARCHAR)) ||
        hstore('cites_NC', MAX((listing -> 'cites_NC')::VARCHAR)) ||
        hstore('cites_listing', ARRAY_TO_STRING(
          -- unnest to filter out the nulls
          ARRAY(SELECT * FROM UNNEST(
            ARRAY[
              (MAX(listing -> 'cites_I')::VARCHAR),
              (MAX(listing -> 'cites_II')::VARCHAR),
              (MAX(listing -> 'cites_III')::VARCHAR),
              (MAX(listing -> 'cites_NC')::VARCHAR)
            ]) s WHERE s IS NOT NULL),
            '/'
          )
        )
        FROM taxon_concepts
          WHERE listing->'cites_status' = 'LISTED'
          AND (listing->'cites_status_original')::BOOLEAN = TRUE
          AND (parent_id = node_id OR id=node_id)
          OR parent_id = node_id;

        UPDATE taxon_concepts
        SET listing = listing - ARRAY['cites_I', 'cites_II', 'cites_III', 'cites_NC'] || tmp
        WHERE id = node_id;
      ELSE
        UPDATE taxon_concepts SET listing = listing ||
        hstore('cites_listing', ARRAY_TO_STRING(
            -- unnest to filter out the nulls
            ARRAY(SELECT * FROM UNNEST(
              ARRAY[listing -> 'cites_I', listing -> 'cites_II', listing -> 'cites_III', listing -> 'cites_NC']) s 
              WHERE s IS NOT NULL),
              '/'
            )
          )
        WHERE id = node_id;
      END IF;
      RETURN;
    END;
  $$;

COMMENT ON FUNCTION apply_children_listing(node_id INTEGER) IS '';

CREATE OR REPLACE FUNCTION rebuild_ancestor_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          cites_eu_id int;
          node_id int;
        BEGIN
          SELECT id INTO cites_eu_id FROM taxonomies WHERE name = 'CITES_EU';
          FOR node_id IN SELECT id FROM taxon_concepts
            WHERE parent_id IS NULL AND taxonomy_id = cites_eu_id
          LOOP
            PERFORM apply_children_listing(node_id);
          END LOOP;
        END;
      $$;

COMMENT ON FUNCTION rebuild_ancestor_listings() IS 'Procedure to rebuild the computed ancestor listings in taxon_concepts.';
