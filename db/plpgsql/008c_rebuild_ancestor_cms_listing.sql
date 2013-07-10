CREATE OR REPLACE FUNCTION cms_aggregate_children_listing(
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
          cms_aggregate_children_listing(id, TRUE)
        WHERE taxon_concepts.parent_id = node_id;
      END IF;

        WITH updated AS (
          WITH aggregated_children_listing AS (
            SELECT
            hstore('cms_I', MAX((listing -> 'cms_I')::VARCHAR)) ||
            hstore('cms_II', MAX((listing -> 'cms_II')::VARCHAR)) ||
            hstore('cms_not_listed', MAX((listing -> 'cms_not_listed')::VARCHAR)) ||
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
            FROM taxon_concepts WHERE parent_id = node_id
              OR (id = node_id AND (listing->'cms_status_original')::BOOLEAN)
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

CREATE OR REPLACE FUNCTION rebuild_ancestor_cms_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      cms_id int;
      ancestor_node_ids INTEGER[];
      tmp_node_id int;
    BEGIN
    SELECT id INTO cms_id FROM taxonomies WHERE name = 'CMS';
    IF node_id IS NOT NULL THEN
      PERFORM cms_aggregate_children_listing(node_id, TRUE);
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
      FOREACH tmp_node_id IN ARRAY ancestor_node_ids
      LOOP
        PERFORM cms_aggregate_children_listing(tmp_node_id, FALSE);
      END LOOP;
    ELSE
      UPDATE taxon_concepts SET listing = taxon_concepts.listing ||
        cms_aggregate_children_listing(id, TRUE)
      WHERE parent_id IS NULL AND taxonomy_id = cms_id;
    END IF;
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_ancestor_cms_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_ancestor_cms_listing_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_ancestor_cms_listing() IS 'Procedure to rebuild EU ancestor listings in taxon_concepts.';
