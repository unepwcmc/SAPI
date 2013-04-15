CREATE OR REPLACE FUNCTION eu_aggregate_children_listing(
  node_id INTEGER, cascade_to_children BOOLEAN
  ) RETURNS HSTORE
  LANGUAGE plpgsql
  AS $$
    DECLARE
      tmp HSTORE;
    BEGIN
      -- this will update the listing only if node is a leaf
      WITH updated AS (
        UPDATE taxon_concepts SET listing = taxon_concepts.listing ||
        hstore(
          'eu_listing',
          ARRAY_TO_STRING(
            -- unnest to filter out the nulls
            ARRAY(
              SELECT * FROM UNNEST(
                ARRAY[
                  taxon_concepts.listing -> 'eu_A',
                  taxon_concepts.listing -> 'eu_B',
                  taxon_concepts.listing -> 'eu_C',
                  taxon_concepts.listing -> 'eu_D',
                  taxon_concepts.listing -> 'eu_not_listed'
                ]
              ) s WHERE s IS NOT NULL
            ), '/'
          )
        )
        FROM taxon_concepts leaves
        WHERE NOT EXISTS (
          SELECT id FROM taxon_concepts WHERE taxon_concepts.parent_id = leaves.id
        ) AND taxon_concepts.id = leaves.id AND leaves.id = node_id
        RETURNING taxon_concepts.id, taxon_concepts.listing
      ) SELECT listing INTO tmp FROM updated LIMIT 1;
      IF FOUND THEN
        RETURN tmp;
      END IF;
      -- if it's not a leaf
      IF cascade_to_children THEN
        UPDATE taxon_concepts SET listing = taxon_concepts.listing ||
          eu_aggregate_children_listing(id, TRUE)
        WHERE taxon_concepts.parent_id = node_id;
      END IF;

        WITH updated AS (
          WITH aggregated_children_listing AS (
            SELECT
            hstore('eu_A', MAX((listing -> 'eu_A')::VARCHAR)) ||
            hstore('eu_B', MAX((listing -> 'eu_B')::VARCHAR)) ||
            hstore('eu_C', MAX((listing -> 'eu_C')::VARCHAR)) ||
            hstore('eu_D', MAX((listing -> 'eu_D')::VARCHAR)) ||
            hstore('eu_not_listed', MAX((listing -> 'eu_not_listed')::VARCHAR)) ||
            hstore('eu_listing', ARRAY_TO_STRING(
              -- unnest to filter out the nulls
              ARRAY(SELECT * FROM UNNEST(
                ARRAY[
                  (MAX(listing -> 'eu_A')::VARCHAR),
                  (MAX(listing -> 'eu_B')::VARCHAR),
                  (MAX(listing -> 'eu_C')::VARCHAR),
                  (MAX(listing -> 'eu_D')::VARCHAR),
                  (MAX(listing -> 'eu_not_listed')::VARCHAR)
                ]) s WHERE s IS NOT NULL),
                '/'
              )
            ) AS listing
            FROM taxon_concepts WHERE parent_id = node_id
              OR (id = node_id AND (listing->'eu_status_original')::BOOLEAN)
          )
          UPDATE taxon_concepts SET listing = taxon_concepts.listing || aggregated_children_listing.listing
          FROM aggregated_children_listing
          WHERE taxon_concepts.id = node_id
          RETURNING taxon_concepts.listing
        )
        SELECT listing INTO tmp FROM updated;

      RETURN tmp;
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_ancestor_eu_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      cites_eu_id int;
      ancestor_node_ids INTEGER[];
      tmp_node_id int;
    BEGIN
    SELECT id INTO cites_eu_id FROM taxonomies WHERE name = 'CITES_EU';
    IF node_id IS NOT NULL THEN
      PERFORM eu_aggregate_children_listing(node_id, TRUE);
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
      FOREACH tmp_node_id IN ARRAY ancestor_node_ids
      LOOP
        PERFORM eu_aggregate_children_listing(tmp_node_id, FALSE);
      END LOOP;
    ELSE
      UPDATE taxon_concepts SET listing = taxon_concepts.listing ||
        eu_aggregate_children_listing(id, TRUE)
      WHERE parent_id IS NULL AND taxonomy_id = cites_eu_id;
    END IF;
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_ancestor_eu_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_ancestor_eu_listing_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_ancestor_eu_listing() IS 'Procedure to rebuild EU ancestor listings in taxon_concepts.';
