CREATE OR REPLACE FUNCTION cites_aggregate_children_listing(
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
          'cites_listing',
          ARRAY_TO_STRING(
            -- unnest to filter out the nulls
            ARRAY(
              SELECT * FROM UNNEST(
                ARRAY[
                  taxon_concepts.listing -> 'cites_I',
                  taxon_concepts.listing -> 'cites_II',
                  taxon_concepts.listing -> 'cites_III',
                  taxon_concepts.listing -> 'cites_not_listed'
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
          cites_aggregate_children_listing(id, TRUE)
        WHERE taxon_concepts.parent_id = node_id;
      END IF;

        WITH updated AS (
          WITH aggregated_children_listing AS (
            SELECT
            -- this to be used in the timelines: if there are explicitly listed
            -- descendants, the timeline might differ from the current listing
            -- and a note should be displayed to inform the user 
            hstore('cites_listed_descendants', BOOL_OR(
              (listing -> 'cites_status_original')::BOOLEAN
              OR (listing -> 'cites_listed_descendants')::BOOLEAN
            )::VARCHAR) ||
            hstore('cites_I', MAX((listing -> 'cites_I')::VARCHAR)) ||
            hstore('cites_II', MAX((listing -> 'cites_II')::VARCHAR)) ||
            hstore('cites_III', MAX((listing -> 'cites_III')::VARCHAR)) ||
            hstore('cites_NC', MAX((listing -> 'cites_not_listed')::VARCHAR)) ||
            hstore('cites_listing', ARRAY_TO_STRING(
              -- unnest to filter out the nulls
              ARRAY(SELECT * FROM UNNEST(
                ARRAY[
                  (MAX(listing -> 'cites_I')::VARCHAR),
                  (MAX(listing -> 'cites_II')::VARCHAR),
                  (MAX(listing -> 'cites_III')::VARCHAR),
                  (MAX(listing -> 'cites_not_listed')::VARCHAR)
                ]) s WHERE s IS NOT NULL),
                '/'
              )
            ) AS listing
            FROM taxon_concepts
            WHERE
              -- aggregate children's listings
              parent_id = node_id
              -- as well as parent if they're explicitly listed
              OR (
                id = node_id 
                AND (listing->'cites_status_original')::BOOLEAN
              )
              -- as well as parent if they are species
              -- the assumption being they will have subspecies
              -- which are not listed in their own right and
              -- should therefore inherit the cascaded listing
              -- if one exists
              -- this should fix Lutrinae species, which should be I/II
              -- even though subspecies in the db are on I
              OR (
                id = node_id 
                AND data->'rank_name' = 'SPECIES'
              )
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

CREATE OR REPLACE FUNCTION rebuild_ancestor_cites_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      cites_eu_id int;
      ancestor_node_ids INTEGER[];
      tmp_node_id int;
    BEGIN
    IF node_id IS NOT NULL THEN
      PERFORM cites_aggregate_children_listing(node_id, TRUE);
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
      FOREACH tmp_node_id IN ARRAY ancestor_node_ids
      LOOP
        PERFORM cites_aggregate_children_listing(tmp_node_id, FALSE);
      END LOOP;
    ELSE
      SELECT id INTO cites_eu_id FROM taxonomies WHERE name = 'CITES_EU';
      UPDATE taxon_concepts SET listing = taxon_concepts.listing ||
        cites_aggregate_children_listing(id, TRUE)
      WHERE parent_id IS NULL AND taxonomy_id = cites_eu_id;
    END IF;
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_ancestor_cites_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_ancestor_cites_listing_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_ancestor_cites_listing() IS 'Procedure to rebuild CITES ancestor listings in taxon_concepts.';
