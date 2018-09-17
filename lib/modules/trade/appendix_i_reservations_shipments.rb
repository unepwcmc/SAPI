class Trade::AppendixIReservationsShipments < Trade::ReservationsShipmentsParser
  attr_reader :query

  RESERVATIONS_PATH = 'lib/data/reservations.csv'.freeze

  VIEW_DIR = 'db/views/trade_shipments_appendix_i_view'.freeze

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
        WHERE #{except}
      )

      ORDER BY s.year, s.class_name, s.order_name, s.family_name, s.genus_name, s.taxon_name, s.term
    SQL
  end

  def except
    where = []
    CSV.foreach(RESERVATIONS_PATH, headers: true) do |row|
      @row = row
      where << "\n\t\t\t\t(#{ATTRIBUTES.map { |a| send("parse_#{a.to_s}", row[a.to_s]) }.join(' AND ')})\n"
    end
    where.join("\n\t\t\t\tOR\n")
  end
end
