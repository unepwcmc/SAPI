DROP FUNCTION IF EXISTS rebuild_valid_species_name_appendix_year_designation_mview(
  designation_name TEXT
  );
CREATE OR REPLACE FUNCTION rebuild_valid_taxon_concept_appendix_year_designation_mview(
  designation_name TEXT
  ) RETURNS VOID
  LANGUAGE plpgsql
  AS $$
  DECLARE
    mview_name TEXT;
    appendix TEXT;
  BEGIN
    IF designation_name = 'EU' THEN
      appendix := 'annex';
    ELSE
      appendix := 'appendix';
    END IF;
    mview_name := 'valid_taxon_concept_' || appendix || '_year_mview';

    EXECUTE 'DROP TABLE IF EXISTS ' || designation_name || '_listing_changes_intervals_mview;';

    EXECUTE 'CREATE TEMP TABLE ' || designation_name || '_listing_changes_intervals_mview AS
    WITH additions_and_deletions AS (
      SELECT change_type_name, effective_at, taxon_concept_id,
      species_listing_name, species_listing_id, party_id
      FROM ' || designation_name || '_listing_changes_mview
      WHERE change_type_name = ''ADDITION'' OR change_type_name = ''DELETION''
    ), additions AS (
      SELECT change_type_name, effective_at, taxon_concept_id,
      species_listing_name, species_listing_id, party_id
      FROM additions_and_deletions
      WHERE change_type_name = ''ADDITION''
    )
    SELECT a.taxon_concept_id, a.species_listing_name,
    a.effective_at AS effective_from,
    MIN(ad.effective_at) AS effective_to
    FROM additions a
    LEFT JOIN additions_and_deletions ad
    ON a.taxon_concept_id = ad.taxon_concept_id
    AND a.species_listing_id = ad.species_listing_id
    AND (a.party_id = ad.party_id OR ad.party_id IS NULL)
    AND a.effective_at < ad.effective_at
    GROUP BY a.taxon_concept_id, a.species_listing_name, a.effective_at';

    -- drop indexes on the mview
    IF designation_name = 'CITES' THEN
      EXECUTE 'DROP INDEX IF EXISTS ' || mview_name || '_year_idx';
    END IF;
    EXECUTE 'DROP INDEX IF EXISTS ' || mview_name || '_idx';
    -- truncate the mview
    EXECUTE 'TRUNCATE ' || mview_name;

    -- the following interval-merging query adapted from Solution 2
    -- http://blog.developpez.com/sqlpro/p9821/langage-sql-norme/agregation_d_intervalles_en_sql_1

    EXECUTE '
    WITH unmerged_intervals AS (
      SELECT F.effective_from, L.effective_to, F.taxon_concept_id, F.species_listing_name
      FROM ' || designation_name || '_listing_changes_intervals_mview AS F
      JOIN ' || designation_name || '_listing_changes_intervals_mview AS L
      ON (F.effective_to <= L.effective_to OR L.effective_to IS NULL)
        AND F.taxon_concept_id = L.taxon_concept_id
        AND F.species_listing_name = L.species_listing_name
      JOIN ' || designation_name || '_listing_changes_intervals_mview AS E
      ON F.taxon_concept_id = E.taxon_concept_id
        AND F.species_listing_name = E.species_listing_name
      GROUP  BY F.effective_from, L.effective_to,  F.taxon_concept_id, F.species_listing_name
      HAVING COUNT(
        CASE
          WHEN (E.effective_from < F.effective_from AND (F.effective_from <= E.effective_to OR E.effective_to IS NULL))  
            OR (E.effective_from <= L.effective_to AND (L.effective_to < E.effective_to OR E.effective_to IS NULL)) 
          THEN 1
        END
      ) = 0
    )
    INSERT INTO ' || mview_name || '
    (taxon_concept_id, ' || appendix || ', effective_from, effective_to)
    SELECT taxon_concept_id, species_listing_name,
    effective_from, MIN(effective_to) AS effective_to
    FROM   unmerged_intervals
    GROUP  BY taxon_concept_id, species_listing_name, effective_from';

    IF designation_name = 'CITES' THEN
      EXECUTE 'CREATE INDEX ' || mview_name || '_year_idx ON ' || mview_name || '(
        taxon_concept_id,
        DATE_PART(''year'', effective_from), DATE_PART(''year'', effective_to), ' ||
        appendix || '
      );';
    END IF;
    EXECUTE 'CREATE INDEX ' || mview_name || '_idx ON ' || mview_name || '
    (taxon_concept_id, effective_from, effective_to, ' || appendix || ');';
  END;
$$;

DROP FUNCTION IF EXISTS rebuild_valid_species_name_annex_year_mview();
CREATE OR REPLACE FUNCTION rebuild_valid_taxon_concept_annex_year_mview() RETURNS VOID
  LANGUAGE sql
  AS $$
    SELECT * FROM rebuild_valid_taxon_concept_appendix_year_designation_mview('EU');
    SELECT * FROM rebuild_ancestor_valid_tc_appdx_year_designation_mview('EU');
$$;

DROP FUNCTION IF EXISTS rebuild_valid_species_name_appendix_year_mview();
CREATE OR REPLACE FUNCTION rebuild_valid_taxon_concept_appendix_year_mview() RETURNS VOID
  LANGUAGE sql
  AS $$
    SELECT * FROM rebuild_valid_taxon_concept_appendix_year_designation_mview('CITES');
    SELECT * FROM rebuild_ancestor_valid_tc_appdx_year_designation_mview('CITES');
    SELECT * FROM rebuild_valid_tc_appdx_N_year_mview();
    SELECT * FROM rebuild_valid_hybrid_appdx_year_mview();
$$;
