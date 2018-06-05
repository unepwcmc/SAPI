class Trade::MandatoryQuotasShipments
  attr_reader :query

  QUOTAS_PATH = 'lib/data/quotas.csv'

  ATTRIBUTES = [:start_date, :end_date, :taxon_concept_id, :iso_code2, :quota,
                :unit, :term, :source, :purpose]

  def initialize
    @query = "#{select} #{from} #{joins} WHERE"
    length = CSV.read(QUOTAS_PATH).length
    CSV.foreach(QUOTAS_PATH, headers: true) do |row|
      @row = row
      @query << "(#{where})"
      #Conjunction if not EOF
      @query << " OR " if $. < length
    end
  end

  private

  def select
    """
      SELECT ts.*, exporters.iso_code2 AS exporter, importers.iso_code2 AS importer,
             source.code AS source, purpose.code AS purpose, unit.code AS unit, term.code AS term
    """.gsub("\n", '')
  end

  def from
    'FROM trade_shipments_with_taxa_view ts'
  end

  def joins
    """
      INNER JOIN geo_entities AS exporters ON exporters.id = ts.exporter_id
      INNER JOIN geo_entities AS importers ON importers.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    """.gsub("\n", '')
  end

  def where
    ATTRIBUTES.map { |a| send("parse_#{a.to_s}", @row[a.to_s]) }.join(' AND ')
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
    ge = @row['applies_to_import'].present? ? 'importers' : 'exporters'
    "#{ge}.iso_code2 = '#{iso}'"
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

    codes = code.split(';')
    where = codes.map { |c| "#{type}.code = '#{c.strip}'" }.join(' OR ')
    "(#{where})"
  end

  def parse_quota(quota)
    "ts.quantity >= #{quota}"
  end
end
