CREATE OR REPLACE FUNCTION rebuild_not_listed_status_for_designation_and_node(
  designation designations, node_id integer
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      exception_id int;
      fully_covered_flag varchar;
      not_listed_flag varchar;
      status_flag varchar;
      listing_original_flag varchar;
      listing_flag varchar;
    BEGIN
    SELECT id INTO exception_id FROM change_types
      WHERE designation_id = designation.id AND name = 'EXCEPTION';

    fully_covered_flag := LOWER(designation.name) || '_fully_covered';
    not_listed_flag := LOWER(designation.name) || '_not_listed';
    status_flag = LOWER(designation.name) || '_status';
    listing_original_flag := LOWER(designation.name) || '_listing_original';
    listing_flag := LOWER(designation.name) || '_listing';

    -- reset the fully_covered flag (so we start clear)
    UPDATE taxon_concepts SET listing = listing - ARRAY[not_listed_flag] ||
      hstore(fully_covered_flag, 't')
    WHERE
      taxonomy_id = designation.taxonomy_id AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    -- set the fully_covered flag to false for taxa with descendants who:
    -- * were deleted from the listing
    -- * were excluded from the listing
    WITH qq AS (
      WITH RECURSIVE q AS (
        SELECT h.id, h.parent_id,
        CASE
          WHEN (listing->status_flag)::VARCHAR = 'DELETED'
            OR (listing->status_flag)::VARCHAR = 'EXCLUDED'
          THEN 't'
          ELSE 'f'
        END AS not_listed
        FROM taxon_concepts h
        WHERE taxonomy_id = designation.taxonomy_id AND (
          listing->status_flag = 'DELETED' OR listing->status_flag = 'EXCLUDED'
        ) AND
        CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END

        UNION

        SELECT hi.id, hi.parent_id,
        CASE
          WHEN (listing->status_flag)::VARCHAR = 'DELETED'
            OR (listing->status_flag)::VARCHAR = 'EXCLUDED'
          THEN 't'
          ELSE not_listed
        END
        FROM taxon_concepts hi
        INNER JOIN    q
        ON      hi.id = q.parent_id
      )
      SELECT id, BOOL_OR((not_listed)::BOOLEAN) AS not_fully_covered
      FROM q 
      GROUP BY id
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(fully_covered_flag, 'f')
      || hstore(not_listed_flag, 'NC') ||
      hstore(listing_original_flag, 'NC')
    FROM qq
    WHERE taxon_concepts.id = qq.id AND qq.not_fully_covered = 't';

    -- set the fully_covered flag to false for taxa which only have some
    -- populations listed
    WITH incomplete_distributions AS (
      SELECT taxon_concept_id AS id FROM listing_distributions
      INNER JOIN listing_changes
        ON listing_changes.id = listing_distributions.listing_change_id
      INNER JOIN change_types
        ON change_types.id = listing_changes.change_type_id AND change_types.designation_id = designation.id
      WHERE is_current = 't' AND NOT listing_distributions.is_party

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
      || hstore(not_listed_flag, 'NC')
    FROM incomplete_distributions
    WHERE taxon_concepts.id = incomplete_distributions.id AND
    CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    UPDATE taxon_concepts
    SET listing = listing ||
    hstore(not_listed_flag, 'NC') || hstore(listing_original_flag, 'NC') || hstore(listing_flag, 'NC')
    WHERE taxonomy_id = designation.taxonomy_id AND (listing->status_flag)::VARCHAR IS NULL
    AND CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    END;
  $$;
