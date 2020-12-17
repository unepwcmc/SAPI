class Trade::CitesSuspensionsShipments < Trade::ComplianceShipmentsParser
  attr_reader :query

  EXEMPTIONS_PATH = 'lib/data/exemptions.csv'.freeze

  VIEW_DIR = 'db/views/trade_shipments_cites_suspensions_view'.freeze

  def initialize
    @query = exceptions_query
  end

  def generate_view(timestamp)
    Dir.mkdir(VIEW_DIR) unless Dir.exists?(VIEW_DIR)
    File.open("#{VIEW_DIR}/#{timestamp}.sql", 'w') { |f| f.write(@query) }
  end

  private

  def exceptions_query
    <<-SQL
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
            ts.year BETWEEN EXTRACT(YEAR FROM tr_tc.start_date)::INTEGER AND
            CASE WHEN tr_tc.end_date IS NULL THEN EXTRACT(YEAR FROM current_date)::INTEGER
            ELSE EXTRACT(YEAR FROM tr_tc.end_date)::INTEGER
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
            ts.year BETWEEN EXTRACT(YEAR FROM tr_ge.start_date)::INTEGER AND
            CASE WHEN tr_ge.end_date IS NULL THEN EXTRACT(YEAR FROM current_date)::INTEGER
            ELSE EXTRACT(YEAR FROM tr_ge.end_date)::INTEGER
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
        WHERE #{except}
      )

      ORDER BY s.year, s.class_name, s.order_name, s.family_name, s.genus_name, s.taxon_name, s.term
    SQL
  end

  def except
    where = []
    CSV.foreach(EXEMPTIONS_PATH, headers: true) do |row|
      @row = row
      where << "\n\t\t\t\t(#{ATTRIBUTES.map { |a| send("parse_#{a.to_s}", row[a.to_s]) }.join(' AND ')})\n"
    end
    where.join("\n\t\t\t\tOR\n")
  end

  def imp_or_exp_country
    @row['applies_to_import'].present? ? 'importers' : 'exporters'
  end
end
