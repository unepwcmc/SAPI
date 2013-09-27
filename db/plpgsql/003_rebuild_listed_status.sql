CREATE OR REPLACE FUNCTION rebuild_listing_status_for_designation_and_node(
  designation designations, node_id integer
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      deletion_id int;
      addition_id int;
      exception_id int;
      status_flag varchar;
      status_original_flag varchar;
      listing_original_flag varchar;
      listing_flag varchar;
      listing_updated_at_flag varchar;
      not_listed_flag varchar;
      show_flag varchar;
      level_of_listing_flag varchar;
      flags_to_reset text[];
    BEGIN
    SELECT id INTO deletion_id FROM change_types
      WHERE designation_id = designation.id AND name = 'DELETION';
    SELECT id INTO addition_id FROM change_types
      WHERE designation_id = designation.id AND name = 'ADDITION';
    SELECT id INTO exception_id FROM change_types
      WHERE designation_id = designation.id AND name = 'EXCEPTION';

    status_flag = LOWER(designation.name) || '_status';
    status_original_flag = LOWER(designation.name) || '_status_original';
    listing_original_flag := LOWER(designation.name) || '_listing_original';
    listing_flag := LOWER(designation.name) || '_listing';
    listing_updated_at_flag = LOWER(designation.name) || '_updated_at';
    level_of_listing_flag := LOWER(designation.name) || '_level_of_listing';
    not_listed_flag := LOWER(designation.name) || '_not_listed';
    show_flag := LOWER(designation.name) || '_show';
    
    
    flags_to_reset := ARRAY[
      status_flag, status_original_flag, listing_flag, listing_original_flag, 
      not_listed_flag, listing_updated_at_flag, level_of_listing_flag,
      show_flag
    ];
    IF designation.name = 'CITES' THEN
      flags_to_reset := flags_to_reset ||
        ARRAY['cites_I','cites_II','cites_III'];
    ELSIF designation.name = 'EU' THEN
      flags_to_reset := flags_to_reset ||
        ARRAY['eu_A','eu_B','eu_C','eu_D'];
    ELSIF designation.name = 'CMS' THEN
      flags_to_reset := flags_to_reset ||
        ARRAY['cms_I','cms_II'];
    END IF;

    -- reset the listing status (so we start clear)
    UPDATE taxon_concepts
    SET listing = (COALESCE(listing, ''::HSTORE) - flags_to_reset)
    WHERE taxonomy_id = designation.taxonomy_id AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    -- set status property to 'LISTED' for all explicitly listed taxa
    -- i.e. ones which have at least one current ADDITION
    -- also set status_original & level_of_listing flags to true
    -- also set the listing_updated_at property
    WITH listed_taxa AS (
      SELECT taxon_concepts.id, MAX(effective_at) AS listing_updated_at
      FROM taxon_concepts
      INNER JOIN listing_changes
        ON taxon_concepts.id = listing_changes.taxon_concept_id
        AND is_current = 't'
        AND change_type_id = addition_id
      WHERE taxonomy_id = designation.taxonomy_id
      GROUP BY taxon_concepts.id
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(status_flag, 'LISTED') ||
      hstore(status_original_flag, 't') ||
      hstore(level_of_listing_flag, 't') ||
      hstore(listing_updated_at_flag, listing_updated_at::VARCHAR)
    FROM listed_taxa
    WHERE taxon_concepts.id = listed_taxa.id AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- set status property to 'EXCLUDED' for all explicitly excluded taxa
    -- omit ones already marked as listed
    -- also set status_original flag to true
    -- note: this was moved before setting the "deleted" status,
    -- because some taxa were deleted but still need to show up
    -- in the checklist, and so they get the "excluded" status
    -- to differentiate them
    WITH excluded_taxa AS (
      WITH listing_exceptions AS (
        SELECT listing_changes.parent_id, taxon_concept_id
        FROM listing_changes
        INNER JOIN taxon_concepts
          ON listing_changes.taxon_concept_id  = taxon_concepts.id
            AND taxonomy_id = designation.taxonomy_id
            AND (
              listing -> status_flag <> 'LISTED'
              OR (listing -> status_flag)::VARCHAR IS NULL
            )
        WHERE change_type_id = exception_id
      )
      SELECT DISTINCT listing_exceptions.taxon_concept_id AS id
      FROM listing_exceptions
      INNER JOIN listing_changes
        ON listing_changes.id = listing_exceptions.parent_id
          AND listing_changes.taxon_concept_id <> listing_exceptions.taxon_concept_id
          AND listing_changes.change_type_id = addition_id
          AND listing_changes.is_current = TRUE
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(status_flag, 'EXCLUDED') ||
      hstore(status_original_flag, 't')
    FROM excluded_taxa
    WHERE taxon_concepts.id = excluded_taxa.id AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- set status property to 'DELETED' for all explicitly deleted taxa
    -- omit ones already marked as listed (applies to appendix III deletions)
    -- also set status_original flag to true
    -- also set a flag if there are listed subspecies of a deleted species
    WITH deleted_taxa AS (
      SELECT taxon_concepts.id
      FROM taxon_concepts
      INNER JOIN listing_changes
        ON taxon_concepts.id = listing_changes.taxon_concept_id
        AND is_current = 't' AND change_type_id = deletion_id
      WHERE taxonomy_id = designation.taxonomy_id AND (
        listing -> status_flag <> 'LISTED'
        AND listing -> status_flag <> 'EXCLUDED'
          OR (listing -> status_flag)::VARCHAR IS NULL
      )
    ), not_really_deleted_taxa AS (
      -- crazy stuff to do with species that were deleted but have listed subspecies
      -- so in fact this is really confusing but what can you do, flag it
        SELECT DISTINCT parent_id AS id
        FROM taxon_concepts
        JOIN deleted_taxa
        ON taxon_concepts.parent_id = deleted_taxa.id
        JOIN ranks
        ON taxon_concepts.rank_id = ranks.id AND ranks.name = 'SUBSPECIES'
        WHERE taxon_concepts.listing->'cites_status' = 'LISTED'
    )
    UPDATE taxon_concepts
    SET listing = listing || hstore(status_flag, 'DELETED') ||
      hstore(status_original_flag, 't') ||
      hstore(
        'not_really_deleted',
        CASE WHEN not_really_deleted_taxa.id IS NOT NULL THEN 't'
        ELSE 'f' END
      )
    FROM deleted_taxa
    LEFT JOIN not_really_deleted_taxa
    ON not_really_deleted_taxa.id = deleted_taxa.id
    WHERE taxon_concepts.id = deleted_taxa.id AND
      CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;

    -- set the level_of_listing flag to false for taxa included in parent listing
    -- unless the inclusion is part of split listing where the other part is actually
    -- an explicit listing
    UPDATE taxon_concepts
    SET listing = listing || hstore(level_of_listing_flag, 'f')
    FROM (
    SELECT taxon_concepts.id
    FROM taxon_concepts
    JOIN listing_changes ON taxon_concepts.id = listing_changes.taxon_concept_id
    JOIN change_types ON change_types.id = listing_changes.change_type_id
    WHERE is_current = TRUE AND designation_id = designation.id
    AND
    CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END
    GROUP BY taxon_concepts.id, designation_id
    HAVING EVERY(inclusion_taxon_concept_id IS NOT NULL)
    ) taxon_concepts_with_inclusions_only
    WHERE taxon_concepts_with_inclusions_only.id = taxon_concepts.id;

    -- propagate cites_status to descendants
    WITH RECURSIVE q AS
    (
      SELECT  h.id, h.parent_id,
      listing->status_flag AS inherited_cites_status,
      listing->listing_updated_at_flag AS inherited_listing_updated_at
      FROM    taxon_concepts h
      WHERE (listing->status_original_flag)::BOOLEAN = 't' AND
        CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END

      UNION

      SELECT  hi.id, hi.parent_id,
      inherited_cites_status,
      inherited_listing_updated_at
      FROM    q
      JOIN    taxon_concepts hi
      ON      hi.parent_id = q.id
      WHERE listing IS NULL OR
        (listing->status_original_flag)::BOOLEAN IS NULL OR
        (listing->status_original_flag)::BOOLEAN = 'f'
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) ||
      hstore(status_flag, inherited_cites_status) ||
      hstore(status_original_flag, 'f') ||
      hstore(not_listed_flag, NULL) ||
      hstore(listing_updated_at_flag, inherited_listing_updated_at)
    FROM q
    WHERE taxon_concepts.id = q.id AND (
      listing IS NULL OR
      (listing->status_original_flag)::BOOLEAN IS NULL OR
      (listing->status_original_flag)::BOOLEAN = 'f'
    );

    -- set cites_status property to 'LISTED' for ancestors of listed taxa
    WITH qq AS (
      WITH RECURSIVE q AS
      (
        SELECT  h.id, h.parent_id,
        listing->status_flag AS inherited_cites_status,
        (listing->listing_updated_at_flag)::TIMESTAMP AS inherited_listing_updated_at
        FROM    taxon_concepts h
        WHERE
          listing->status_flag = 'LISTED'
          AND (listing->status_original_flag)::BOOLEAN = 't'
          AND
          CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END

        UNION

        SELECT  hi.id, hi.parent_id,
        CASE
          WHEN (listing->status_original_flag)::BOOLEAN = 't'
          THEN listing->status_flag
          ELSE inherited_cites_status
        END,
        CASE
          WHEN (listing->listing_updated_at_flag)::TIMESTAMP IS NOT NULL
          THEN (listing->listing_updated_at_flag)::TIMESTAMP
          ELSE inherited_listing_updated_at
        END
        FROM    q
        JOIN    taxon_concepts hi
        ON      hi.id = q.parent_id
        WHERE (listing->status_original_flag)::BOOLEAN IS NULL
      )
      SELECT DISTINCT id, inherited_cites_status,
        inherited_listing_updated_at
      FROM q
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) ||
      hstore(status_flag, inherited_cites_status) ||
      hstore(status_original_flag, 'f') ||
      hstore(level_of_listing_flag, 'f') ||
      hstore(listing_updated_at_flag, inherited_listing_updated_at::VARCHAR)
    FROM qq
    WHERE taxon_concepts.id = qq.id
     AND (
       listing IS NULL
       OR (listing->status_original_flag)::BOOLEAN IS NULL
       OR (listing->status_original_flag)::BOOLEAN = 'f'
     );

    END;
  $$;
