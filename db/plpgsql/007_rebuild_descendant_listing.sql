CREATE OR REPLACE FUNCTION rebuild_descendant_listing_for_designation_and_node(
  designation designations, node_id integer
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      ancestor_node_id integer;
      fully_covered_flag varchar;
      not_listed_flag varchar;
      status_original_flag varchar;
      status_flag varchar;
      listing_original_flag varchar;
      listing_flag varchar;
      level_of_listing_flag varchar;
    BEGIN

    fully_covered_flag := LOWER(designation.name) || '_fully_covered';
    not_listed_flag := LOWER(designation.name) || '_not_listed';
    status_original_flag := LOWER(designation.name) || '_status_original';
    status_flag := LOWER(designation.name) || '_status';
    listing_original_flag := LOWER(designation.name) || '_listing_original';
    listing_flag := LOWER(designation.name) || '_listing';
    level_of_listing_flag := LOWER(designation.name) || '_level_of_listing';

    IF node_id IS NOT NULL THEN
      WITH RECURSIVE ancestors AS (
        SELECT h.id, h.parent_id, h.listing
        FROM taxon_concepts h WHERE id = node_id

        UNION

        SELECT hi.id, hi.parent_id, hi.listing
        FROM taxon_concepts hi JOIN ancestors ON hi.id = ancestors.parent_id
      )
      SELECT id INTO ancestor_node_id
      FROM ancestors
      WHERE (listing->status_original_flag)::BOOLEAN = TRUE
      LIMIT 1;

      IF FOUND THEN
        node_id := ancestor_node_id;
      END IF;
    END IF;

    WITH RECURSIVE q AS (
      SELECT h.id, parent_id,
      hstore(listing_flag,
        CASE
          WHEN listing->status_flag = 'LISTED'
          THEN listing->listing_original_flag
          WHEN listing->not_listed_flag = 'NC'
          THEN listing->not_listed_flag
          ELSE NULL
        END
      )  ||
      slice(h.listing, ARRAY[listing_original_flag, fully_covered_flag,'hash_ann_symbol', 'ann_symbol']) ||
      CASE
        WHEN designation.name = 'CITES' THEN slice(h.listing, ARRAY['cites_I', 'cites_II', 'cites_III'])
        WHEN designation.name = 'EU' THEN slice(h.listing, ARRAY['eu_A', 'eu_B', 'eu_C', 'eu_D'])
        WHEN designation.name = 'CMS' THEN slice(h.listing, ARRAY['cms_I', 'cms_II'])
        ELSE ''::HSTORE
      END
      AS inherited_listing
      FROM taxon_concepts h
      WHERE listing->status_original_flag = 't' AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END

      UNION

      SELECT hi.id, hi.parent_id,
      CASE
      WHEN
        hi.listing->status_original_flag = 't'
      THEN
        hstore(listing_flag, hi.listing->listing_original_flag) ||
        slice(hi.listing, ARRAY[listing_original_flag, fully_covered_flag,'hash_ann_symbol', 'ann_symbol']) ||
        CASE
          WHEN designation.name = 'CITES' THEN slice(hi.listing, ARRAY['cites_I', 'cites_II', 'cites_III'])
          WHEN designation.name = 'EU' THEN slice(hi.listing, ARRAY['eu_A', 'eu_B', 'eu_C', 'eu_D'])
          WHEN designation.name = 'CMS' THEN slice(hi.listing, ARRAY['cms_I', 'cms_II'])
          ELSE ''::HSTORE
        END
      ELSE
        inherited_listing
      END
      FROM q
      JOIN taxon_concepts hi
      ON hi.parent_id = q.id
    )
    UPDATE taxon_concepts
    SET
    listing = listing ||
    CASE
    WHEN listing->status_flag = 'EXCLUDED' OR listing->status_flag = 'DELETED'
    THEN q.inherited_listing - ARRAY[not_listed_flag]
    ELSE q.inherited_listing
    END
    FROM q
    WHERE taxon_concepts.id = q.id;
    END;
  $$;

