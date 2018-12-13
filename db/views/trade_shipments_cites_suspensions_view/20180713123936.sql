      SELECT DISTINCT *
      FROM(
        -- Fetch all shipments where taxon concepts are specified in CITES Suspension.
        -- It considers also the geo_entity if specified in the Suspension as well as sources and purposes if any.
        (
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
                 NULL AS origin,
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
                 'Suspension' AS issue_type,
                 start_notifications.subtype AS details_of_compliance_issue,
                 start_notifications.effective_at AS compliance_type_start_date,
                 ts.taxon_concept_full_name AS compliance_type_taxon,
                 ranks.id AS rank_id,
                 ranks.name AS rank_name,
                 end_notifications.effective_at AS compliance_type_end_date,
                 start_notifications.name AS suspension_start_notification, end_notifications.name AS suspension_end_notification,
                 tr_tc.notes AS notes
          FROM trade_shipments_with_taxa_view ts
          INNER JOIN taxon_concepts_and_ancestors_mview tca ON ts.taxon_concept_id = tca.taxon_concept_id
          INNER JOIN trade_restrictions tr_tc ON tr_tc.taxon_concept_id = tca.ancestor_taxon_concept_id
          INNER JOIN events start_notifications ON tr_tc.start_notification_id  = start_notifications.id
          INNER JOIN geo_entities importers ON ts.importer_id = importers.id
          INNER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
          INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
          LEFT OUTER JOIN geo_entities suspension_countries ON tr_tc.geo_entity_id = suspension_countries.id
          LEFT OUTER JOIN events end_notifications ON tr_tc.end_notification_id = end_notifications.id
          LEFT OUTER JOIN trade_restriction_sources tr_s ON tr_tc.id = tr_s.trade_restriction_id
          LEFT OUTER JOIN trade_restriction_purposes tr_p ON tr_tc.id = tr_p.trade_restriction_id
          LEFT OUTER JOIN trade_codes sources ON sources.id = ts.source_id
          LEFT OUTER JOIN trade_codes purposes ON purposes.id = ts.purpose_id
          LEFT OUTER JOIN trade_codes units ON units.id = ts.unit_id
          LEFT OUTER JOIN trade_codes terms ON terms.id = ts.term_id
          WHERE tr_tc.type = 'CitesSuspension' AND
          ts.appendix != 'N' AND
          start_notifications.type = 'CitesSuspensionNotification' AND
          start_notifications.subtype NOT IN ('National trade ban (communicated by MA)', 'Information notice') AND
          end_notifications.type = 'CitesSuspensionNotification' AND
          end_notifications.subtype NOT IN ('National trade ban (communicated by MA)', 'Information notice') AND
          (
            ts.year BETWEEN EXTRACT(YEAR FROM tr_tc.start_date) AND
            CASE WHEN tr_tc.end_date IS NULL THEN EXTRACT(YEAR FROM current_date)
            ELSE EXTRACT(YEAR FROM tr_tc.end_date)
            END
          )AND
          (tr_tc.geo_entity_id IS NULL OR (tr_tc.geo_entity_id = ts.exporter_id OR tr_tc.geo_entity_id = ts.importer_id AND tr_tc.applies_to_import)) AND
          (tr_s.source_id = ts.source_id OR tr_s.id IS NULL) AND (tr_p.purpose_id = ts.purpose_id OR tr_p.id IS NULL) AND country_of_origin_id IS NULL AND
          (sources.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
        )

        UNION

        -- Fetch all shipments where geo entities are specified in CITES Suspension, both for importer and exporter.
        -- It considers also taxon concepts if specified in the Suspension as well as sources and purposes if any.

        (
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
                 NULL AS origin,
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
                 'Suspension' AS issue_type,
                 start_notifications.subtype AS details_of_compliance_issue,
                 start_notifications.effective_at AS start_date,
                 ts.taxon_concept_full_name AS compliance_type_taxon,
                 ranks.id AS rank_id,
                 ranks.name AS rank_name,
                 end_notifications.effective_at AS end_date,
                 start_notifications.name AS suspension_start_notification, end_notifications.name AS suspension_end_notification,
                 tr_ge.notes AS notes
          FROM trade_shipments_with_taxa_view ts
          INNER JOIN trade_restrictions tr_ge ON tr_ge.geo_entity_id = ts.exporter_id OR (tr_ge.geo_entity_id = ts.importer_id AND tr_ge.applies_to_import)
          INNER JOIN events start_notifications ON tr_ge.start_notification_id  = start_notifications.id
          INNER JOIN geo_entities importers ON ts.importer_id = importers.id
          INNER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
          LEFT OUTER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
          LEFT OUTER JOIN geo_entities suspension_countries ON tr_ge.geo_entity_id = suspension_countries.id
          LEFT OUTER JOIN events end_notifications ON tr_ge.end_notification_id = end_notifications.id
          LEFT OUTER JOIN trade_restriction_sources tr_s ON tr_ge.id = tr_s.trade_restriction_id
          LEFT OUTER JOIN trade_restriction_purposes tr_p ON tr_ge.id = tr_p.trade_restriction_id
          LEFT OUTER JOIN trade_codes sources ON sources.id = ts.source_id
          LEFT OUTER JOIN trade_codes purposes ON purposes.id = ts.purpose_id
          LEFT OUTER JOIN trade_codes units ON units.id = ts.unit_id
          LEFT OUTER JOIN trade_codes terms ON terms.id = ts.term_id
          WHERE tr_ge.type = 'CitesSuspension' AND
          ts.appendix != 'N' AND
          start_notifications.type = 'CitesSuspensionNotification' AND
          start_notifications.subtype NOT IN ('National trade ban (communicated by MA)', 'Information notice') AND
          end_notifications.type = 'CitesSuspensionNotification' AND
          end_notifications.subtype NOT IN ('National trade ban (communicated by MA)', 'Information notice') AND
          (tr_ge.taxon_concept_id IS NULL OR tr_ge.taxon_concept_id = ts.taxon_concept_id) AND
          (
            ts.year BETWEEN EXTRACT(YEAR FROM tr_ge.start_date) AND
            CASE WHEN tr_ge.end_date IS NULL THEN EXTRACT(YEAR FROM current_date)
            ELSE EXTRACT(YEAR FROM tr_ge.end_date)
            END
          )AND
          (tr_s.source_id = ts.source_id OR tr_s.id IS NULL) AND (tr_p.purpose_id = ts.purpose_id OR tr_p.id IS NULL) AND country_of_origin_id IS NULL AND
          (sources.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
        )
      ) AS s

      WHERE s.id NOT IN (
        SELECT ts.id
        FROM trade_shipments_with_taxa_view ts
        INNER JOIN geo_entities importers ON ts.importer_id = importers.id
        INNER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
        INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
        LEFT OUTER JOIN trade_codes sources ON sources.id = ts.source_id
        LEFT OUTER JOIN trade_codes purposes ON purposes.id = ts.purpose_id
        LEFT OUTER JOIN trade_codes units ON units.id = ts.unit_id
        LEFT OUTER JOIN trade_codes terms ON terms.id = ts.term_id
        WHERE 
				(ts.year >= 2018 AND ts.year <= 2018 AND TRUE AND exporters.iso_code2 = 'IN' AND TRUE AND TRUE AND sources.code IN ('A','C','D','F','I','O','R','U','X') AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2011 AND ts.year <= 2014 AND TRUE AND exporters.iso_code2 = 'PY' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 1999 AND ts.year <= 2018 AND TRUE AND exporters.iso_code2 = 'IN' AND TRUE AND TRUE AND sources.code IN ('A','C','D','F','I','O','R','U','X') AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2004 AND ts.year <= 2018 AND TRUE AND exporters.iso_code2 = 'SO' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2006 AND ts.year <= 2016 AND TRUE AND exporters.iso_code2 = 'SO' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2005 AND ts.year <= 2018 AND TRUE AND exporters.iso_code2 = 'AF' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2004 AND ts.year <= 2018 AND TRUE AND exporters.iso_code2 = 'MR' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2018 AND ts.year <= 2018 AND TRUE AND exporters.iso_code2 = 'LR' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2016 AND ts.year <= 2018 AND TRUE AND exporters.iso_code2 = 'GW' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2016 AND ts.year <= 2018 AND TRUE AND exporters.iso_code2 = 'LR' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2016 AND ts.year <= 2016 AND TRUE AND exporters.iso_code2 = 'AO' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2016 AND ts.year <= 2016 AND TRUE AND exporters.iso_code2 = 'LA' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2015 AND TRUE AND exporters.iso_code2 = 'CD' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2015 AND TRUE AND exporters.iso_code2 = 'LA' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND TRUE AND exporters.iso_code2 = 'NG' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2011 AND ts.year <= 2018 AND TRUE AND exporters.iso_code2 = 'DJ' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2011 AND ts.year <= 2014 AND ts.taxon_concept_id = 23851 AND exporters.iso_code2 = 'PY' AND TRUE AND terms.code IN ('OIL','TIM') AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2006 AND ts.year <= 2018 AND ts.taxon_concept_id = 55214 AND exporters.iso_code2 = 'AR' AND TRUE AND terms.code IN ('TRO') AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2006 AND ts.year <= 2018 AND ts.taxon_concept_id = 5390 AND exporters.iso_code2 = 'AR' AND TRUE AND TRUE AND sources.code IN ('R') AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 5734 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 5734 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 5734 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 5734 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3151 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3151 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3151 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3151 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3411 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3411 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3411 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3411 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 10706 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 10706 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 10706 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 10706 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 6828 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 6828 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 6828 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 6828 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 5858 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 5858 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 5858 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 5858 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 4830 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 4830 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 4830 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 4830 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3078 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3078 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3078 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3078 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 9527 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 9527 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 9527 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 9527 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3359 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3359 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3359 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3359 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3362 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3362 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3362 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3362 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3686 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3686 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3686 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3686 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3604 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3604 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3604 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3604 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 10503 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 10503 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 10503 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 10503 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 11228 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 11228 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 11228 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 11228 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 7304 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 7304 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 7304 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 7304 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2011 AND ts.year <= 2014 AND ts.taxon_concept_id = 6048 AND exporters.iso_code2 = 'PY' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3390 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3390 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3390 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3390 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 5493 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 5493 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 5493 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 5493 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 6377 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 6377 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 6377 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 6377 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 6242 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 6242 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 6242 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 6242 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 5707 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 5707 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 5707 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 5707 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 7542 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 7542 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 7542 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 7542 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3293 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3293 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3293 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3293 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 8011 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 8011 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 8011 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 8011 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 5979 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 5979 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 5979 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 5979 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 9004 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 9004 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 9004 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 9004 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 5547 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 5547 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 5547 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 5547 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2006 AND ts.year <= 2018 AND ts.taxon_concept_id = 8246 AND exporters.iso_code2 = 'AR' AND TRUE AND terms.code IN ('TRO') AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 9590 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 9590 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 9590 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 9590 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3930 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3930 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3930 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3930 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 7052 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 7052 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 7052 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 7052 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 3477 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 3477 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 3477 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 3477 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 8779 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 8779 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 8779 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 8779 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2015 AND ts.year <= 2016 AND ts.taxon_concept_id = 6940 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2014 AND ts.year <= 2015 AND ts.taxon_concept_id = 6940 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2013 AND ts.year <= 2014 AND ts.taxon_concept_id = 6940 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2013 AND ts.taxon_concept_id = 6940 AND exporters.iso_code2 = 'MG' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2006 AND ts.year <= 2018 AND ts.taxon_concept_id = 6330 AND exporters.iso_code2 = 'AR' AND TRUE AND terms.code IN ('TRO') AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7903 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6659 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 11020 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4989 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8288 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6477 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 3975 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6352 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10905 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4329 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9445 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 3052 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7265 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10200 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4438 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5314 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5623 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5924 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 3327 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8462 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7046 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9702 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7197 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9180 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 3918 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6793 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7504 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8540 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10842 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8788 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10448 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9382 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 11005 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6391 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7820 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6795 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4962 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10624 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8824 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 34009 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 67921 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5245 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8989 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 11236 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10064 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8215 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10191 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6629 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4770 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 67922 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7086 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5138 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 67923 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4021 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4061 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8842 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4206 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8084 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8608 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 68342 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9803 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 11079 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 11185 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5652 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5385 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4956 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6515 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6532 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10761 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7010 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7840 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9048 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4979 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 3957 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9126 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6238 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7528 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10363 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10436 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8883 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10466 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6913 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 3188 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 68344 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5644 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8066 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8865 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8605 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6746 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4039 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8310 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5326 AND TRUE AND TRUE AND TRUE AND TRUE AND purposes.code IN ('Z','G','Q','S','H','P','M','E','N','B','L') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7265 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10200 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4438 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5314 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5623 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5924 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 3327 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8462 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7046 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9702 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7197 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9180 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 3918 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6793 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7504 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8540 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10842 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8788 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10448 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9382 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 11005 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6391 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7820 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6795 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4962 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10624 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8824 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 34009 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 67921 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5245 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8989 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 11236 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10064 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8215 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10191 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6629 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4770 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 67922 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7086 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5138 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 67923 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4021 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4061 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8842 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4206 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8084 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8608 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 68342 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9803 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 11079 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 11185 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5652 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5385 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4956 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7010 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7840 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9048 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4979 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 3957 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 9126 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6238 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 7528 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10363 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10436 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8883 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 10466 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6913 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 3188 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 68344 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5644 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8066 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8865 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8605 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 6746 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 4039 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 8310 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2012 AND ts.year <= 2015 AND ts.taxon_concept_id = 5326 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

      )

      ORDER BY s.year, s.class_name, s.order_name, s.family_name, s.genus_name, s.taxon_name, s.term
