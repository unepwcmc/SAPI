class Trade::MandatoryQuotasShipments
  attr_reader :final_query

  QUOTAS_PATH = 'lib/data/quotas.csv'.freeze

  VIEW_DIR = 'db/views/trade_shipments_mandatory_quotas_view'.freeze

  SELECT = {
    shipment_id: 'ts.id AS shipment_id',
    year: 'ts.year AS year',
    appendix: 'ts.appendix AS appendix',
    taxon: 'ts.taxon_concept_full_name AS taxon',
    class: 'ts.taxon_concept_class_name AS class',
    order: 'ts.taxon_concept_order_name AS order',
    family: 'ts.taxon_concept_family_name AS family',
    genus: 'ts.taxon_concept_genus_name AS genus',
    exporter_quantity: 'CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_quantity',
    importer_quantity: 'CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_quantity',
    unit: 'unit.name_en AS unit',
    importer: 'importer.iso_code2 AS importer',
    exporter: 'exporter.iso_code2 AS exporter',
    origin: 'NULL AS origin',
    purpose: 'purpose.name_en AS purpose',
    source: 'source.name_en AS source',
    term: 'term.name_en AS term',
    import_permits: 'ts.import_permits_ids AS import_permits',
    export_permits: 'ts.export_permits_ids AS export_permits',
    origin_permits: 'ts.origin_permits_ids AS origin_permits',
    issue_type: "'Quota' AS issue_type",
    quota_type: 'quota_type',
    compliance_start_date: 'start_date',
    compliance_end_date: 'end_date',
    compliance_taxon: 'taxon',
    compliance_taxon_rank: 'rank',
    quota_quantity: 'quantity',
    notes: 'notes'
  }

  INNER_SELECT = [
    'year', 'purpose.name_en', 'source.name_en', 'term.name_en', 'unit.name_en',
    'taxon_concept_id'
  ]

  ATTRIBUTES = [
    :start_date, :end_date, :taxon_concept_id, :iso_code2,
    :unit, :term, :source, :purpose, :origin
  ]

  def initialize
    @queries = []
    CSV.foreach(QUOTAS_PATH, headers: true) do |row|
      @row = row
      run
    end
    @final_query = @queries.join("\n\s\s\s\sUNION\s\s\s\s\n")
  end

  def generate_view(timestamp)
    Dir.mkdir(VIEW_DIR) unless Dir.exists?(VIEW_DIR)
    #timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    File.open("#{VIEW_DIR}/#{timestamp}.sql", 'w') { |f| f.write(@final_query) }
  end

  private

  def run
    @queries << query
  end

  def db
    ActiveRecord::Base.connection
  end

  def query
    """
    (
      SELECT #{sanitised_select}
      #{from}
      #{joins}
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          #{sub_query}
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    """
  end

  def sub_query
    """
          #{inner_select}
          #{from}
          #{inner_joins}
          WHERE #{where}
          #{group_by}
          #{having}
    """
  end

  def sanitised_select
    SELECT.merge({
      quota_type: "'#{@row['quota_type']}' AS details_of_compliance_issue",
      compliance_start_date: "'#{@row['start_date']}' AS compliance_type_start_date",
      compliance_end_date: "'#{@row['end_date']}' AS compliance_type_end_date",
      compliance_taxon: "'#{@row['taxon_name']}' AS compliance_type_taxon",
      compliance_taxon_rank: "'#{@row['rank']}' AS compliance_type_taxonomic_rank",
      quota_quantity: "'#{@row['quota']}' AS quota_quantity",
      notes: "'#{@row['notes']}' AS notes"
    }).values.join(',')
  end

  def inner_select
    "SELECT ARRAY_AGG(ts.id) AS ids"
  end

  def from
    'FROM trade_shipments_with_taxa_view ts'
  end

  def joins
    """
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    """
  end

  def inner_joins
    """
          INNER JOIN geo_entities AS #{imp_or_exp_country} ON #{imp_or_exp_country}.id = ts.#{imp_or_exp_country}_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    """
  end

  def where
    ATTRIBUTES.map { |a| send("parse_#{a.to_s}", @row[a.to_s]) }.join(' AND ')
  end

  def group_by
    "GROUP BY year, reported_by_exporter"
  end

  def having
    "HAVING SUM(quantity) > #{@row['quota']}"
  end

  def parse_start_date(date)
    year = date.split('/').last.to_i
    "ts.year >= #{year}"
  end

  def parse_end_date(date)
    year = date == 'Present' ? Date.today.year  : date.split('/').last.to_i
    "ts.year <= #{year}"
  end

  def parse_iso_code2(iso)
    return 'TRUE' if iso == 'All' || iso.blank?
    "#{imp_or_exp_country}.iso_code2 = '#{iso}'"
  end

  def parse_taxon_concept_id(tc)
    "ts.taxon_concept_id = #{tc}"
  end

  def parse_unit(unit)
    parse_trade_code(unit, 'unit')
  end

  def parse_term(term)
    parse_trade_code(term, 'term')
  end

  def parse_purpose(purpose)
    parse_trade_code(purpose, 'purpose')
  end

  def parse_source(source)
    parse_trade_code(source, 'source')
  end

  def parse_trade_code(code, type)
    #Return TRUE to prevent empty conditions and a malformed query
    return 'TRUE' if code == 'All' || code.blank?

    codes = code.split(';').map(&:strip)
    "#{type}.code IN (#{codes.map{|c| "'#{c}'"}.join(',')})"
  end

  def parse_origin(origin)
    "ts.country_of_origin_id IS NULL"
  end

  def imp_or_exp_country
    @row['applies_to_import'].present? ? 'importer' : 'exporter'
  end

  def imp_or_exp_country_reverse
    ['importer', 'exporter'].tap { |arr| arr.delete(imp_or_exp) }.first
  end
end