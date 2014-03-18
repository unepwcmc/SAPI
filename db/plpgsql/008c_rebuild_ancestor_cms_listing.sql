DROP FUNCTION IF EXISTS cms_aggregate_children_listing(
  node_id INTEGER, cascade_to_children BOOLEAN
  );

CREATE OR REPLACE FUNCTION cms_leaf_listing(node_id INT)
  RETURNS HSTORE
  LANGUAGE sql STABLE
  AS $$
    SELECT hstore(
      'cms_listing',
      ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(
          SELECT * FROM UNNEST(
            ARRAY[
              taxon_concepts.listing -> 'cms_I',
              taxon_concepts.listing -> 'cms_II',
              taxon_concepts.listing -> 'cms_not_listed'
            ]
          ) s WHERE s IS NOT NULL
        ), '/'
      )
    )
    FROM taxon_concepts
    WHERE id = $1;
  $$;

CREATE OR REPLACE FUNCTION cms_aggregate_children_listing(node_id INT)
  RETURNS HSTORE
  LANGUAGE sql STABLE
  AS $$
    WITH aggregated_children_listing AS (
      SELECT
      -- this to be used in the timelines: if there are explicitly listed
      -- descendants, the timeline might differ from the current listing
      -- and a note should be displayed to inform the user
      hstore('cms_listed_descendants', BOOL_OR(
        (listing -> 'cms_status_original')::BOOLEAN
        OR (listing -> 'cms_listed_descendants')::BOOLEAN
      )::VARCHAR) ||
      hstore('cms_I', MAX((listing -> 'cms_I')::VARCHAR)) ||
      hstore('cms_II', MAX((listing -> 'cms_II')::VARCHAR)) ||
      hstore('cms_NC', MAX((listing -> 'cms_not_listed')::VARCHAR)) ||
      hstore('cms_listing', ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(SELECT * FROM UNNEST(
          ARRAY[
            (MAX(listing -> 'cms_I')::VARCHAR),
            (MAX(listing -> 'cms_II')::VARCHAR),
            (MAX(listing -> 'cms_not_listed')::VARCHAR)
          ]) s WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM taxon_concepts
      WHERE
        -- NOTE: THIS WHERE CLAUSE DIFFERS FROM CITES & EU
        -- aggregate children's listings
        parent_id = $1
        -- as well as parent if they're explicitly listed
        OR (
          id = $1
          AND (listing->'cms_status_original')::BOOLEAN
        )
    )
    SELECT listing
    FROM aggregated_children_listing;
  $$;

CREATE OR REPLACE FUNCTION rebuild_ancestor_cms_listing_recursively_for_node(node_id integer)
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
        PERFORM rebuild_ancestor_cms_listing_recursively_for_node(tmp_node_id);
      END LOOP;

      -- update this node's aggregated listing
      IF ARRAY_UPPER(children_node_ids, 1) IS NULL THEN
        UPDATE taxon_concepts
        SET listing = listing || cms_leaf_listing(node_id)
        WHERE id = node_id;
      ELSE
        UPDATE taxon_concepts
        SET listing = listing || cms_aggregate_children_listing(node_id)
        WHERE id = node_id;
      END IF;
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_ancestor_cms_listing_for_node(node_id integer)
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
          AND taxonomies.name = 'CMS'
          WHERE parent_id IS NULL
        LOOP
          PERFORM rebuild_ancestor_cms_listing_for_node(tmp_node_id);
        END LOOP;
        RETURN;
      END IF;
      PERFORM rebuild_ancestor_cms_listing_recursively_for_node(node_id);
      -- if we're not starting from root, we need to update ancestors
      -- up till root
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
      FOREACH tmp_node_id IN ARRAY ancestor_node_ids
      LOOP
        UPDATE taxon_concepts
        SET listing  = listing || cms_aggregate_children_listing(tmp_node_id)
        WHERE id = tmp_node_id;
      END LOOP;
    END;
  $$;


CREATE OR REPLACE FUNCTION rebuild_ancestor_cms_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      PERFORM rebuild_ancestor_cms_listing_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_ancestor_cms_listing() IS 'Procedure to rebuild CITES ancestor listings in taxon_concepts.';
