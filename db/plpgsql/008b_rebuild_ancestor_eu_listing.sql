DROP FUNCTION IF EXISTS eu_aggregate_children_listing(
  node_id INTEGER, cascade_to_children BOOLEAN
  );

CREATE OR REPLACE FUNCTION eu_leaf_listing(node_id INT)
  RETURNS HSTORE
  LANGUAGE sql STABLE
  AS $$
    SELECT hstore(
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
    FROM taxon_concepts
    WHERE id = $1;
  $$;

CREATE OR REPLACE FUNCTION eu_aggregate_children_listing(node_id INT)
  RETURNS HSTORE
  LANGUAGE sql STABLE
  AS $$
    WITH aggregated_children_listing AS (
      SELECT
      -- this to be used in the timelines: if there are explicitly listed
      -- descendants, the timeline might differ from the current listing
      -- and a note should be displayed to inform the user
      hstore('eu_listed_descendants', BOOL_OR(
        (listing -> 'eu_status_original')::BOOLEAN
        OR (listing -> 'eu_listed_descendants')::BOOLEAN
      )::VARCHAR) ||
      hstore('eu_A', MAX((listing -> 'eu_A')::VARCHAR)) ||
      hstore('eu_B', MAX((listing -> 'eu_B')::VARCHAR)) ||
      hstore('eu_C', MAX((listing -> 'eu_C')::VARCHAR)) ||
      hstore('eu_D', MAX((listing -> 'eu_D')::VARCHAR)) ||
      hstore('eu_NC', MAX((listing -> 'eu_not_listed')::VARCHAR)) ||
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
      FROM taxon_concepts
      WHERE
        -- aggregate children's listings
        parent_id = $1
        -- as well as parent if they're explicitly listed
        OR (
          id = $1
          AND (listing->'eu_status_original')::BOOLEAN
        )
        -- as well as parent if they are species
        -- the assumption being they will have subspecies
        -- which are not listed in their own right and
        -- should therefore inherit the cascaded listing
        -- if one exists
        -- this should fix Lutrinae species, which should be I/II
        -- even though subspecies in the db are on I
        OR (
          id = $1
          AND data->'rank_name' = 'SPECIES'
        )
    )
    SELECT listing
    FROM aggregated_children_listing;
  $$;

CREATE OR REPLACE FUNCTION rebuild_ancestor_eu_listing_recursively_for_node(node_id integer)
  RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      children_node_ids INTEGER[];
      tmp_node_id INT;
    BEGIN
      SELECT ARRAY_AGG_NOTNULL(id) INTO children_node_ids
      FROM taxon_concepts
      WHERE parent_id = node_id;
      -- if there are children, rebuild their aggregated listing first
      FOREACH tmp_node_id IN ARRAY children_node_ids
      LOOP
        PERFORM rebuild_ancestor_eu_listing_recursively_for_node(tmp_node_id);
      END LOOP;

      -- update this node's aggregated listing
      IF ARRAY_UPPER(children_node_ids, 1) IS NULL THEN
        UPDATE taxon_concepts
        SET listing = listing || eu_leaf_listing(node_id)
        WHERE id = node_id;
      ELSE
        UPDATE taxon_concepts
        SET listing = listing || eu_aggregate_children_listing(node_id)
        WHERE id = node_id;
      END IF;
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_ancestor_eu_listing_for_node(node_id integer)
  RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      ancestor_node_ids INTEGER[];
      tmp_node_id int;
    BEGIN
      IF node_id IS NULL THEN
        FOR tmp_node_id IN SELECT taxon_concepts.id FROM taxon_concepts
          JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
          AND taxonomies.name = 'CITES_EU'
          WHERE parent_id IS NULL
        LOOP
          PERFORM rebuild_ancestor_eu_listing_for_node(tmp_node_id);
        END LOOP;
        RETURN;
      END IF;
      PERFORM rebuild_ancestor_eu_listing_recursively_for_node(node_id);
      -- if we're not starting from root, we need to update ancestors
      -- up till root
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
      FOREACH tmp_node_id IN ARRAY ancestor_node_ids
      LOOP
        UPDATE taxon_concepts
        SET listing  = listing || eu_aggregate_children_listing(tmp_node_id)
        WHERE id = tmp_node_id;
      END LOOP;
    END;
  $$;


CREATE OR REPLACE FUNCTION rebuild_ancestor_eu_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      PERFORM rebuild_ancestor_eu_listing_for_node(NULL);
    END;
  $$;