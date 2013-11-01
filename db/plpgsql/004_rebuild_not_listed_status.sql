CREATE OR REPLACE FUNCTION rebuild_not_listed_status_for_designation_and_node(
  designation designations, node_id integer
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      exception_id int;
      fully_covered_flag varchar;
      not_listed_flag varchar;
      status_original_flag varchar;
      status_flag varchar;
      listing_original_flag varchar;
      listing_flag varchar;
      listed_ancestors_flag varchar;
      ancestor_node_ids INTEGER[];
      show_flag varchar;
    BEGIN
    SELECT id INTO exception_id FROM change_types
      WHERE designation_id = designation.id AND name = 'EXCEPTION';

    fully_covered_flag := LOWER(designation.name) || '_fully_covered';
    not_listed_flag := LOWER(designation.name) || '_not_listed';
    status_original_flag := LOWER(designation.name) || '_status_original';
    status_flag = LOWER(designation.name) || '_status';
    listing_original_flag := LOWER(designation.name) || '_listing_original';
    listing_flag := LOWER(designation.name) || '_listing';
    listed_ancestors_flag := LOWER(designation.name) || '_listed_ancestors';
    show_flag := LOWER(designation.name) || '_show';

    -- reset the fully_covered flag (so we start clear)
    -- also set the listed ancestors flag to true
    UPDATE taxon_concepts SET listing = listing - ARRAY[not_listed_flag] ||
      hstore(fully_covered_flag, 't') ||
      hstore(listed_ancestors_flag, 't')
    WHERE
      taxonomy_id = designation.taxonomy_id AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    -- set the fully_covered flag to false for taxa
    -- that were deleted or excluded from the listing
    WITH deleted_or_excluded AS (
      SELECT id,
        CASE
          WHEN (listing->status_flag)::VARCHAR = 'DELETED'
            OR (listing->status_flag)::VARCHAR = 'EXCLUDED'
          THEN 't'
          ELSE 'f'
        END AS not_listed
      FROM taxon_concepts
      WHERE
        taxonomy_id = designation.taxonomy_id
        AND listing->status_flag IN ('DELETED', 'EXCLUDED')
        AND CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END
    )
    UPDATE taxon_concepts
    SET listing = listing ||
      hstore(fully_covered_flag, 'f') ||
      hstore(listing_original_flag, 'NC')
    FROM deleted_or_excluded
    WHERE taxon_concepts.id = deleted_or_excluded.id;

    -- set the fully_covered flag to false for taxa
    -- that only have some populations listed

    WITH incomplete_distributions AS (
      SELECT taxon_concept_id AS id FROM listing_distributions
      INNER JOIN listing_changes
        ON listing_changes.id = listing_distributions.listing_change_id
      INNER JOIN change_types
        ON change_types.id = listing_changes.change_type_id 
        AND change_types.designation_id = designation.id
        AND change_types.name = 'ADDITION'
      WHERE is_current = 't'
        AND NOT listing_distributions.is_party
        AND CASE WHEN node_id IS NOT NULL THEN listing_changes.taxon_concept_id = node_id ELSE TRUE END

      EXCEPT

      SELECT taxon_concept_id AS id FROM listing_distributions
      RIGHT JOIN listing_changes
        ON listing_changes.id = listing_distributions.listing_change_id
      INNER JOIN taxon_concepts
        ON taxon_concepts.id = listing_changes.taxon_concept_id
      WHERE is_current = 't' AND taxonomy_id = designation.taxonomy_id
        AND (listing_distributions.id IS NULL OR listing_distributions.is_party)
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(fully_covered_flag, 'f')
    FROM incomplete_distributions
    WHERE taxon_concepts.id = incomplete_distributions.id;

    -- set the fully_covered flag to false for taxa
    -- that do not have a cascaded listing
    -- also set the 'has_listed_ancestors' flag to false

    WITH RECURSIVE taxa_without_cascaded_listing AS (
      SELECT id
      FROM taxon_concepts 
      WHERE taxonomy_id = designation.taxonomy_id
        AND parent_id IS NULL

      UNION

      SELECT hi.id
      FROM taxon_concepts hi
      JOIN taxa_without_cascaded_listing
      ON taxa_without_cascaded_listing.id = hi.parent_id
      AND NOT (hi.listing->status_original_flag)::BOOLEAN
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(fully_covered_flag, 'f') || hstore(listed_ancestors_flag, 'f')
    FROM taxa_without_cascaded_listing
    WHERE taxon_concepts.id = taxa_without_cascaded_listing.id
      AND NOT (listing->status_original_flag)::BOOLEAN
      AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- propagate the fully_covered flag to ancestors
    -- update the nc flag for all that are not fully covered
    WITH RECURSIVE not_fully_covered AS (
      SELECT id, parent_id
      FROM taxon_concepts
      WHERE taxonomy_id = designation.taxonomy_id
        AND NOT (listing->fully_covered_flag)::BOOLEAN
        AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END

      UNION

      SELECT h.id, h.parent_id
      FROM taxon_concepts h
      JOIN not_fully_covered
      ON h.id = not_fully_covered.parent_id
    )
    UPDATE taxon_concepts
    SET listing = listing ||
      hstore(fully_covered_flag, 'f') || hstore(not_listed_flag, 'NC')
    FROM not_fully_covered
    WHERE taxon_concepts.id = not_fully_covered.id;

    -- update the nc flags for all leftovers
    UPDATE taxon_concepts
    SET listing = listing ||
    hstore(not_listed_flag, 'NC') || hstore(listing_original_flag, 'NC') || hstore(listing_flag, 'NC')
    WHERE taxonomy_id = designation.taxonomy_id 
      AND (listing->status_flag)::VARCHAR IS NULL
      AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    IF node_id IS NOT NULL THEN
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
    END IF;

    -- set designation_show to true for all taxa except:
    -- implicitly listed subspecies
    -- hybrids
    -- excluded and not listed taxa
    -- higher taxa (incl. genus) that do not have a cascaded listing
    UPDATE taxon_concepts SET listing = listing ||
    CASE
      WHEN name_status = 'H'
      THEN hstore(show_flag, 'f')
      WHEN (
        data->'rank_name' = 'SUBSPECIES'
        OR data->'rank_name' = 'VARIETY'
      )
      AND listing->status_flag = 'LISTED'
      AND (listing->status_original_flag)::BOOLEAN = FALSE
      THEN hstore(show_flag, 'f')  
      WHEN NOT (
        data->'rank_name' = 'SPECIES'
      )
      AND listing->status_flag = 'LISTED'
      AND (listing->status_original_flag)::BOOLEAN = FALSE
      AND (listing->listed_ancestors_flag)::BOOLEAN = FALSE
      THEN hstore(show_flag, 'f')
      WHEN listing->status_flag = 'EXCLUDED'
      THEN hstore(show_flag, 't')
      WHEN listing->status_flag = 'DELETED'
        AND (listing->'not_really_deleted')::BOOLEAN = TRUE
      THEN hstore(show_flag, 't')
      WHEN listing->status_flag = 'DELETED'
        OR (listing->status_flag)::VARCHAR IS NULL
      THEN hstore(show_flag, 'f')
      ELSE hstore(show_flag, 't')
    END
    WHERE taxonomy_id = designation.taxonomy_id AND
    CASE WHEN node_id IS NOT NULL THEN id IN (SELECT id FROM UNNEST(ancestor_node_ids)) ELSE TRUE END;

    END;
  $$;
