    SELECT DISTINCT *
    FROM (
      SELECT ts.id, ts.year, ts.appendix, ts.taxon_concept_id,
             ts.taxon_concept_author_year AS author_year,
             ts.taxon_concept_name_status AS name_status,
             ts.taxon_concept_full_name AS taxon_name,
             ts.taxon_concept_phylum_id AS phylum_id,
             ts.taxon_concept_class_id AS class_id,
             ts.taxon_concept_class_name AS class_name,
             ts.taxon_concept_order_id AS order_id,
             ts.taxon_concept_order_name AS order_name,
             ts.taxon_concept_family_id AS family_id,
             ts.taxon_concept_family_name AS family_name,
             ts.taxon_concept_genus_id AS genus_id,
             ts.taxon_concept_genus_name AS genus_name,
             terms.id AS term_id,
             terms.name_en AS term,
             CASE WHEN ts.reported_by_exporter IS FALSE THEN ts.quantity
                  ELSE NULL
             END AS importer_reported_quantity,
             CASE WHEN ts.reported_by_exporter IS TRUE THEN ts.quantity
                  ELSE NULL
             END AS exporter_reported_quantity,
             units.id AS unit_id,
             units.name_en AS unit,
             exporters.id AS exporter_id,
             exporters.iso_code2 AS exporter_iso,
             exporters.name_en AS exporter,
             importers.id AS importer_id,
             importers.iso_code2 AS importer_iso,
             importers.name_en AS importer,
             origins.iso_code2 AS origin,
             purposes.id AS purpose_id,
             purposes.name_en AS purpose,
             sources.id AS source_id,
             sources.name_en AS source,
             ts.import_permits_ids AS import_permits,
             ts.export_permits_ids AS export_permits,
             ts.origin_permits_ids AS origin_permits,
             ts.import_permit_number AS import_permit,
             ts.export_permit_number AS export_permit,
             ts.origin_permit_number AS origin_permit,
             ranks.id AS rank_id,
             ranks.name AS rank_name,
             'AppendixI'::text AS issue_type
      FROM trade_shipments_with_taxa_view ts
      INNER JOIN trade_codes sources ON ts.source_id = sources.id
      INNER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
      INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
      LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
      LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
      LEFT OUTER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
      LEFT OUTER JOIN geo_entities importers ON ts.importer_id = importers.id
      LEFT OUTER JOIN geo_entities origins ON ts.country_of_origin_id = origins.id
      WHERE ts.appendix = 'I'
        AND purposes.type = 'Purpose'
        AND purposes.code = 'T'
        AND sources.type = 'Source'
        AND sources.code IN ('W', 'X', 'F', 'R')
      )
    AS s

      WHERE s.id NOT IN (
        SELECT ts.id
        FROM trade_shipments_with_taxa_view ts
        INNER JOIN geo_entities importers ON ts.importer_id = importers.id
        INNER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
        WHERE
				(ts.year > 1991 AND ts.year < 2018 AND ts.taxon_concept_id = 8935 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'NA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'NA')))

				OR

				(ts.year > 1991 AND ts.year < 2018 AND ts.taxon_concept_id = 1929 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'NA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'NA')))

				OR

				(ts.year > 2003 AND ts.year < 2014 AND ts.taxon_concept_id = 3721 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 2003 AND ts.year < 2014 AND ts.taxon_concept_id = 3721 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'LI')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'LI')))

				OR

				(ts.year > 2003 AND ts.year < 2018 AND ts.taxon_concept_id = 3721 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PH')))

				OR

				(ts.year > 2003 AND ts.year < 2014 AND ts.taxon_concept_id = 11033 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 2003 AND ts.year < 2014 AND ts.taxon_concept_id = 11033 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'LI')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'LI')))

				OR

				(ts.year > 2003 AND ts.year < 2018 AND ts.taxon_concept_id = 11033 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PH')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 9871 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 6741 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1985 AND ts.year < 2014 AND ts.taxon_concept_id = 4650 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1985 AND ts.year < 2014 AND ts.taxon_concept_id = 4650 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'LI')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'LI')))

				OR

				(ts.year > 1985 AND ts.year < 2018 AND ts.taxon_concept_id = 4650 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SR')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SR')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 8288 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'IS')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'IS')))

				OR

				(ts.year > 1986 AND ts.year < 2018 AND ts.taxon_concept_id = 8288 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 1986 AND ts.year < 2018 AND ts.taxon_concept_id = 8288 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'NO')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'NO')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 8288 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 6477 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'IS')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'IS')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 6477 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 1986 AND ts.year < 2018 AND ts.taxon_concept_id = 6477 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'NO')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'NO')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 3975 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'IS')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'IS')))

				OR

				(ts.year > 1981 AND ts.year < 2018 AND ts.taxon_concept_id = 3975 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 1981 AND ts.year < 2018 AND ts.taxon_concept_id = 3975 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'NO')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'NO')))

				OR

				(ts.year > 1983 AND ts.year < 2018 AND ts.taxon_concept_id = 6352 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 10905 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'IS')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'IS')))

				OR

				(ts.year > 1983 AND ts.year < 2018 AND ts.taxon_concept_id = 4329 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 9445 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'IS')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'IS')))

				OR

				(ts.year > 1981 AND ts.year < 2018 AND ts.taxon_concept_id = 9445 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 1981 AND ts.year < 2018 AND ts.taxon_concept_id = 9445 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'NO')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'NO')))

				OR

				(ts.year > 1983 AND ts.year < 2018 AND ts.taxon_concept_id = 9048 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 7286 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 12278 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 12278 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 7286 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 4442 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 12299 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 12299 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'MK')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'MK')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 12168 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 12168 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'MK')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'MK')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 4442 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'MK')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'MK')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 12199 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 12199 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'MK')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'MK')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 12320 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 12320 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'MK')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'MK')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 4645 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1987 AND ts.year < 2014 AND ts.taxon_concept_id = 8725 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1987 AND ts.year < 2014 AND ts.taxon_concept_id = 8725 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'LI')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'LI')))

				OR

				(ts.year > 1990 AND ts.year < 2018 AND ts.taxon_concept_id = 11071 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CU')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CU')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 11071 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1981 AND ts.year < 2018 AND ts.taxon_concept_id = 11071 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SR')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SR')))

				OR

				(ts.year > 2013 AND ts.year < 2015 AND ts.taxon_concept_id = 6337 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CA')))

				OR

				(ts.year > 2013 AND ts.year < 2015 AND ts.taxon_concept_id = 10248 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CA')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 9020 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 6280 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 12205 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 2010 AND ts.year < 2013 AND ts.taxon_concept_id = 7747 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CA')))

				OR

				(ts.year > 2010 AND ts.year < 2013 AND ts.taxon_concept_id = 10745 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CA')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 8560 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1981 AND ts.year < 2018 AND ts.taxon_concept_id = 4062 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SR')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SR')))

				OR

				(ts.year > 1992 AND ts.year < 2014 AND ts.taxon_concept_id = 12629 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1992 AND ts.year < 2014 AND ts.taxon_concept_id = 12629 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'LI')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'LI')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 3515 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1987 AND ts.year < 2014 AND ts.taxon_concept_id = 6833 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1987 AND ts.year < 2014 AND ts.taxon_concept_id = 6833 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'LI')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'LI')))

				OR

				(ts.year > 1980 AND ts.year < 2018 AND ts.taxon_concept_id = 12165 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 1990 AND ts.year < 2018 AND ts.taxon_concept_id = 7257 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CU')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CU')))

				OR

				(ts.year > 1980 AND ts.year < 2018 AND ts.taxon_concept_id = 12248 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 7257 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1989 AND ts.year < 2018 AND ts.taxon_concept_id = 7257 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'VC')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'VC')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 7466 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 8607 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 12193 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 9441 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 12238 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 10464 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 12332 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 12332 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 12249 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 12249 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 6244 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 6244 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 12254 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 12254 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 3922 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 7821 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 2013 AND ts.year < 2015 AND ts.taxon_concept_id = 6341 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 10054 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 12220 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 10804 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 3792 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 4979 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'IS')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'IS')))

				OR

				(ts.year > 1990 AND ts.year < 2018 AND ts.taxon_concept_id = 4521 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'MW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'MW')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 3052 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'IS')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'IS')))

				OR

				(ts.year > 1989 AND ts.year < 2018 AND ts.taxon_concept_id = 3052 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'VC')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'VC')))

				OR

				(ts.year > 1992 AND ts.year < 2014 AND ts.taxon_concept_id = 14450 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1992 AND ts.year < 2014 AND ts.taxon_concept_id = 14450 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'LI')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'LI')))

				OR

				(ts.year > 1992 AND ts.year < 2014 AND ts.taxon_concept_id = 26732 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1992 AND ts.year < 2014 AND ts.taxon_concept_id = 26732 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'LI')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'LI')))

				OR

				(ts.year > 1992 AND ts.year < 2014 AND ts.taxon_concept_id = 17592 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1992 AND ts.year < 2014 AND ts.taxon_concept_id = 17592 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'LI')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'LI')))

				OR

				(ts.year > 1992 AND ts.year < 2014 AND ts.taxon_concept_id = 22677 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1992 AND ts.year < 2014 AND ts.taxon_concept_id = 22677 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'LI')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'LI')))

				OR

				(ts.year > 2010 AND ts.year < 2013 AND ts.taxon_concept_id = 5003 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CA')))

				OR

				(ts.year > 2005 AND ts.year < 2018 AND ts.taxon_concept_id = 9382 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 2005 AND ts.year < 2018 AND ts.taxon_concept_id = 11005 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 2000 AND ts.year < 2018 AND ts.taxon_concept_id = 10761 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'IS')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'IS')))

				OR

				(ts.year > 1981 AND ts.year < 2018 AND ts.taxon_concept_id = 10761 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'JP')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'JP')))

				OR

				(ts.year > 1981 AND ts.year < 2018 AND ts.taxon_concept_id = 10761 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'NO')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'NO')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 10761 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 9919 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 2013 AND ts.year < 2015 AND ts.taxon_concept_id = 531 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CA')))

				OR

				(ts.year > 2013 AND ts.year < 2015 AND ts.taxon_concept_id = 8391 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CA')))

				OR

				(ts.year > 2003 AND ts.year < 2018 AND ts.taxon_concept_id = 5863 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PH')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 9151 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 2013 AND ts.year < 2015 AND ts.taxon_concept_id = 3592 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CA')))

				OR

				(ts.year > 2017 AND ts.year < 2018 AND ts.taxon_concept_id = 9644 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'AE')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'AE')))

				OR

				(ts.year > 2017 AND ts.year < 2018 AND ts.taxon_concept_id = 9644 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CD')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CD')))

				OR

				(ts.year > 2017 AND ts.year < 2018 AND ts.taxon_concept_id = 9644 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 3627 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 8325 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 3198 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 3370 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 5781 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 2004 AND ts.year < 2018 AND ts.taxon_concept_id = 7938 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'PW')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'PW')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 24119 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 2013 AND ts.year < 2015 AND ts.taxon_concept_id = 4306 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CA')))

				OR

				(ts.year > 1979 AND ts.year < 2014 AND ts.taxon_concept_id = 12206 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'CH')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'CH')))

				OR

				(ts.year > 1996 AND ts.year < 2018 AND ts.taxon_concept_id = 4494 AND ((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = 'SA')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = 'SA')))

      )

      ORDER BY s.year, s.class_name, s.order_name, s.family_name, s.genus_name, s.taxon_name, s.term
