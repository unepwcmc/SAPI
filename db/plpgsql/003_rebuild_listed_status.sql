CREATE OR REPLACE FUNCTION rebuild_listing_status_for_designation_and_node(
  designation designations, node_id integer
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      deletion_id int;
      addition_id int;
      exception_id int;
      designation_name TEXT;
      status_flag varchar;
      status_original_flag varchar;
      listing_original_flag varchar;
      listing_flag varchar;
      listing_updated_at_flag varchar;
      not_listed_flag varchar;
      show_flag varchar;
      level_of_listing_flag varchar;
      flags_to_reset text[];
      sql TEXT;
      tmp_current_listing_changes_mview TEXT;
    BEGIN
    SELECT id INTO deletion_id FROM change_types
      WHERE designation_id = designation.id AND name = 'DELETION';
    SELECT id INTO addition_id FROM change_types
      WHERE designation_id = designation.id AND name = 'ADDITION';
    SELECT id INTO exception_id FROM change_types
      WHERE designation_id = designation.id AND name = 'EXCEPTION';
    designation_name = LOWER(designation.name);
    status_flag = designation_name || '_status';
    status_original_flag = designation_name || '_status_original';
    listing_original_flag := designation_name || '_listing_original';
    listing_flag := designation_name || '_listing';
    listing_updated_at_flag = designation_name || '_updated_at';
    level_of_listing_flag := designation_name || '_level_of_listing';
    not_listed_flag := designation_name || '_not_listed';
    show_flag := designation_name || '_show';
    
    
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
    -- that is not an inclusion
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
      AND inclusion_taxon_concept_id IS NULL
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
        WHERE taxon_concepts.listing->status_flag = 'LISTED'
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

    -- propagate cites_status to descendants
    SELECT listing_changes_mview_name('tmp_current', designation.name, NULL)
    INTO tmp_current_listing_changes_mview;

    sql := 'WITH RECURSIVE q AS (
      SELECT
        h.id,
        h.parent_id,
        listing->''' || designation_name || '_status'' AS inherited_status,
        listing->''' || designation_name || '_updated_at'' AS inherited_listing_updated_at,
        listed_geo_entities_ids,
        excluded_geo_entities_ids,
        excluded_taxon_concept_ids,
        HSTORE(''' || designation_name || '_status_original'', ''t'') || 
        CASE 
          WHEN lc.change_type_name = ''DELETION''
          THEN HSTORE(''' || designation_name || '_status'',  ''DELETED'') || 
            HSTORE(''' || designation_name || '_not_listed'', ''NC'')
          ELSE HSTORE(''' || designation_name || '_status'',  ''LISTED'') || 
            HSTORE(''' || designation_name || '_not_listed'', NULL)
        END AS status_hstore
      FROM    taxon_concepts h
      JOIN ' || tmp_current_listing_changes_mview || ' lc
      ON h.id = lc.taxon_concept_id
      AND lc.change_type_name IN (''ADDITION'', ''DELETION'')
      AND inclusion_taxon_concept_id IS NULL
      GROUP BY
        h.id,
        listed_geo_entities_ids,
        excluded_geo_entities_ids,
        excluded_taxon_concept_ids,
        lc.change_type_name

      UNION

      SELECT
        hi.id,
        hi.parent_id,
        inherited_status,
        inherited_listing_updated_at,
        listed_geo_entities_ids,
        excluded_geo_entities_ids,
        excluded_taxon_concept_ids,
        CASE
        WHEN (hi.listing->''' || designation_name || '_status_original'')::BOOLEAN
        THEN SLICE(hi.listing, ARRAY[
          ''' || designation_name || '_status_original'', 
          ''' || designation_name || '_status'', 
          ''' || designation_name || '_level_of_listing'',
          ''' || designation_name || '_updated_at'', 
          ''' || designation_name || '_not_listed''
        ])
        ELSE
          HSTORE(''' || designation_name || '_status_original'', ''f'') ||
            HSTORE(''' || designation_name || '_level_of_listing'', ''f'') ||
            CASE
              WHEN ARRAY_UPPER(excluded_taxon_concept_ids, 1) IS NOT NULL 
                AND excluded_taxon_concept_ids @> ARRAY[hi.id]
              THEN HSTORE(''' || designation_name || '_status'', ''EXCLUDED'') || 
                HSTORE(''' || designation_name || '_not_listed'', ''NC'')
              WHEN ARRAY_UPPER(excluded_geo_entities_ids, 1) IS NOT NULL 
                AND EXISTS (
                SELECT 1 FROM distributions
                WHERE q.excluded_geo_entities_ids @> ARRAY[geo_entity_id]
                  AND taxon_concept_id = hi.id
              )
              THEN HSTORE(''' || designation_name || '_status'', ''EXCLUDED'') ||
                HSTORE(''' || designation_name || '_not_listed'', ''NC'')
              WHEN ARRAY_UPPER(listed_geo_entities_ids, 1) IS NOT NULL 
                AND NOT EXISTS (
                SELECT 1 FROM distributions
                WHERE q.listed_geo_entities_ids @> ARRAY[geo_entity_id]
                  AND taxon_concept_id = hi.id
              )
              THEN HSTORE(''' || designation_name || '_status'', NULL) ||
                HSTORE(''' || designation_name || '_not_listed'', ''NC'')
              ELSE HSTORE(
                ''' || designation_name || '_status'',
                q.status_hstore->''' || designation_name || '_status''
              ) || HSTORE(
              ''' || designation_name || '_not_listed'',
              q.status_hstore->''' || designation_name || '_not_listed''
              )
            END
        END
      FROM q
      JOIN taxon_concepts hi
        ON hi.parent_id = q.id      
    ), grouped AS (
      SELECT id, 
      HSTORE(
        ''' || designation_name || '_status'',
        CASE
          WHEN BOOL_OR(status_hstore->''' || designation_name || '_status'' = ''LISTED'')
          THEN ''LISTED''
          ELSE MAX(status_hstore->''' || designation_name || '_status'')
        END
      ) ||
      HSTORE(
        ''' || designation_name || '_status_original'',
        BOOL_OR((status_hstore->''' || designation_name || '_status_original'')::BOOLEAN)::TEXT
      ) ||
      HSTORE(
        ''' || designation_name || '_not_listed'',
        CASE
          WHEN BOOL_AND(status_hstore->''' || designation_name || '_not_listed'' = ''NC'')
          THEN ''NC''
          ELSE NULL
        END
      ) ||
      HSTORE(
        ''' || designation_name || '_updated_at'',
        MAX(inherited_listing_updated_at)
      ) AS status_hstore
    FROM q
    GROUP BY q.id --this grouping is to accommodate for split listings
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''''::HSTORE) || grouped.status_hstore
    FROM grouped
    WHERE taxon_concepts.id = grouped.id';

    EXECUTE sql;

    -- set cites_status property to 'LISTED' for ancestors of listed taxa
    WITH qq AS (
      WITH RECURSIVE q AS
      (
        SELECT  h.id, h.parent_id,
        listing->status_flag AS inherited_status,
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
          ELSE inherited_status
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
      SELECT DISTINCT id, inherited_status,
        inherited_listing_updated_at
      FROM q
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) ||
      hstore(status_flag, inherited_status) ||
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


CREATE OR REPLACE FUNCTION set_cites_eu_historically_listed_flag_for_node(designation text, node_id integer)
  RETURNS VOID
  LANGUAGE sql
  AS $$
    WITH historically_listed_taxa AS (
      SELECT taxon_concept_id AS id
      FROM listing_changes
      JOIN change_types
      ON change_types.id = change_type_id
      JOIN designations
      ON designations.id = designation_id AND designations.name = UPPER($1)
      WHERE CASE WHEN $2 IS NULL THEN TRUE ELSE taxon_concept_id = $2 END
      GROUP BY taxon_concept_id
    ), taxa_with_historically_listed_flag AS (
      SELECT taxon_concepts.id,
      CASE WHEN t.id IS NULL THEN FALSE ELSE TRUE END AS historically_listed
      FROM taxon_concepts
      JOIN taxonomies
      ON taxonomies.id = taxon_concepts.taxonomy_id AND taxonomies.name = 'CITES_EU'
      LEFT JOIN historically_listed_taxa t
      ON t.id = taxon_concepts.id
      WHERE CASE WHEN $2 IS NULL THEN TRUE ELSE taxon_concepts.id = $2 END
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) ||
    HSTORE(LOWER($1) || '_historically_listed', t.historically_listed::VARCHAR)
    FROM taxa_with_historically_listed_flag t
    WHERE t.id = taxon_concepts.id;
  $$;
