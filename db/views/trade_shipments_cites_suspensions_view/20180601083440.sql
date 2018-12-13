      SELECT DISTINCT *
      FROM(
        -- Fetch all shipments where taxon concepts are specified in CITES Suspension.
        -- It considers also the geo_entity if specified in the Suspension as well as sources and purposes if any.
        (
          SELECT ts.id, ts.year, ts.appendix, ts.taxon_concept_id,
                 ts.taxon_concept_full_name AS taxon,
                 ts.taxon_concept_class_name AS class,
                 ts.taxon_concept_order_name AS order,
                 ts.taxon_concept_family_name AS family,
                 ts.taxon_concept_genus_name AS genus,
                 terms.name_en AS term,
                 CASE WHEN ts.reported_by_exporter IS FALSE THEN ts.quantity
                      ELSE NULL
                 END AS importer_reported_quantity,
                 CASE WHEN ts.reported_by_exporter IS TRUE THEN ts.quantity
                      ELSE NULL
                 END AS exporter_reported_quantity,
                 units.name_en AS unit, exporters.iso_code2 AS exporter, importers.iso_code2 AS importer, NULL AS origin,
                 purposes.name_en AS purpose, sources.name_en AS source, ts.import_permit_number AS import_permit,
                 ts.export_permit_number AS export_permit, ts.origin_permit_number AS origin_permit, 'Suspension' AS issue_type,
                 start_notifications.subtype AS details_of_compliance_issue,
                 start_notifications.effective_at AS compliance_type_start_date,
                 ts.taxon_concept_full_name AS compliance_type_taxon,
                 ranks.name AS compliance_type_taxonomic_rank,
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
          LEFT OUTER JOIN trade_codes sources ON sources.id = tr_s.source_id
          LEFT OUTER JOIN trade_codes purposes ON purposes.id = tr_p.purpose_id
          LEFT OUTER JOIN trade_codes units ON units.id = ts.unit_id
          LEFT OUTER JOIN trade_codes terms ON terms.id = ts.term_id
          WHERE tr_tc.type = 'CitesSuspension' AND
          start_notifications.type = 'CitesSuspensionNotification' AND
          end_notifications.type = 'CitesSuspensionNotification' AND
          (
            ts.year BETWEEN EXTRACT(YEAR FROM tr_tc.start_date) AND
            CASE WHEN tr_tc.end_date IS NULL THEN EXTRACT(YEAR FROM current_date)
            ELSE EXTRACT(YEAR FROM tr_tc.end_date)
            END
          )AND
          (tr_tc.geo_entity_id IS NULL OR (tr_tc.geo_entity_id = ts.exporter_id OR tr_tc.geo_entity_id = ts.importer_id AND tr_tc.applies_to_import)) AND
          (tr_s.source_id = ts.source_id OR tr_s.id IS NULL) AND (tr_p.purpose_id = ts.purpose_id OR tr_p.id IS NULL) AND country_of_origin_id IS NULL
        )

        UNION

        -- Fetch all shipments where geo entities are specified in CITES Suspension, both for importer and exporter.
        -- It considers also taxon concepts if specified in the Suspension as well as sources and purposes if any.

        (
          SELECT ts.id, ts.year, ts.appendix, ts.taxon_concept_id,
                 ts.taxon_concept_full_name AS taxon,
                 ts.taxon_concept_class_name AS class,
                 ts.taxon_concept_order_name AS order,
                 ts.taxon_concept_family_name AS family,
                 ts.taxon_concept_genus_name AS genus,
                 terms.name_en AS term,
                 CASE WHEN ts.reported_by_exporter IS FALSE THEN ts.quantity
                      ELSE NULL
                 END AS importer_reported_quantity,
                 CASE WHEN ts.reported_by_exporter IS TRUE THEN ts.quantity
                      ELSE NULL
                 END AS exporter_reported_quantity,
                 units.name_en AS unit, exporters.iso_code2 AS exporter, importers.iso_code2 AS importer, NULL AS origin,
                 purposes.name_en AS purpose, sources.name_en AS source, ts.import_permit_number AS import_permit,
                 ts.export_permit_number AS export_permit, ts.origin_permit_number AS origin_permit, 'Suspension' AS issue_type,
                 start_notifications.subtype AS details_of_compliance_issue,
                 start_notifications.effective_at AS start_date,
                 ts.taxon_concept_full_name AS compliance_type_taxon,
                 ranks.name AS compliance_type_taxonomic_rank,
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
          LEFT OUTER JOIN trade_codes sources ON sources.id = tr_s.source_id
          LEFT OUTER JOIN trade_codes purposes ON purposes.id = tr_p.purpose_id
          LEFT OUTER JOIN trade_codes units ON units.id = ts.unit_id
          LEFT OUTER JOIN trade_codes terms ON terms.id = ts.term_id
          WHERE tr_ge.type = 'CitesSuspension' AND
          (tr_ge.taxon_concept_id IS NULL OR tr_ge.taxon_concept_id = ts.taxon_concept_id) AND
          (
            ts.year BETWEEN EXTRACT(YEAR FROM tr_ge.start_date) AND
            CASE WHEN tr_ge.end_date IS NULL THEN EXTRACT(YEAR FROM current_date)
            ELSE EXTRACT(YEAR FROM tr_ge.end_date)
            END
          )AND
          (tr_s.source_id = ts.source_id OR tr_s.id IS NULL) AND (tr_p.purpose_id = ts.purpose_id OR tr_p.id IS NULL) AND country_of_origin_id IS NULL
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

				(ts.year >= 2003 AND ts.year <= 2018 AND ts.taxon_concept_id = 38 AND exporters.iso_code2 = 'JO' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('S') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2011 AND ts.year <= 2014 AND ts.taxon_concept_id = 23851 AND exporters.iso_code2 = 'PY' AND TRUE AND terms.code IN ('OIL','TIM') AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2009 AND ts.year <= 2018 AND ts.taxon_concept_id = 12491 AND exporters.iso_code2 = 'PE' AND TRUE AND TRUE AND sources.code IN ('A') AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2009 AND ts.year <= 2018 AND ts.taxon_concept_id = 12491 AND exporters.iso_code2 = 'PE' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('S') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2009 AND ts.year <= 2018 AND ts.taxon_concept_id = 12491 AND exporters.iso_code2 = 'PE' AND TRUE AND terms.code IN ('FLO') AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

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

				(ts.year >= 2009 AND ts.year <= 2018 AND ts.taxon_concept_id = 12509 AND exporters.iso_code2 = 'PE' AND TRUE AND TRUE AND sources.code IN ('A') AND TRUE AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2009 AND ts.year <= 2018 AND ts.taxon_concept_id = 12509 AND exporters.iso_code2 = 'PE' AND TRUE AND TRUE AND TRUE AND purposes.code IN ('S') AND ts.country_of_origin_id IS NULL)

				OR

				(ts.year >= 2009 AND ts.year <= 2018 AND ts.taxon_concept_id = 12509 AND exporters.iso_code2 = 'PE' AND TRUE AND terms.code IN ('FLO') AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL)

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

      )

      ORDER BY s.year, s.class, s.order, s.family, s.genus, s.taxon, s.term
