class Trade::MandatoryQuotasShipments
  attr_reader :query, :result

  QUOTAS_PATH = 'lib/data/quotas.csv'

  SELECT = [
    'year', 'purpose.name_en', 'source.name_en', 'term.name_en', 'unit.name_en',
    'taxon_concept_id'
  ]

  ATTRIBUTES = [
    :start_date, :end_date, :taxon_concept_id, :iso_code2,
    :unit, :term, :source, :purpose, :origin
  ]

  def initialize
    @result = []
    CSV.foreach(QUOTAS_PATH, headers: true) do |row|
      @row = row
      run
    end
  end

  def run
    @result << db.execute(query)
  end

  private

  def db
    ActiveRecord::Base.connection
  end

  def query
    """
      SELECT *
      #{from}
      WHERE id IN (
        SELECT UNNEST(sub.ids)
        FROM (#{sub_query}) sub
      )
    """.gsub("\n", '')
  end

  def sub_query
    """
      #{select}
      #{from}
      #{joins}
      WHERE #{where}
      #{group_by}
      #{having}
    """.gsub("\n", '')
  end

  def select
    "SELECT #{SELECT.join(',')}, #{imp_or_exp}.iso_code2, SUM(quantity) AS quota, ARRAY_AGG(ts.id) AS ids"
  end

  def from
    'FROM trade_shipments_with_taxa_view ts'
  end

  def joins
    """
      INNER JOIN geo_entities AS #{imp_or_exp} ON #{imp_or_exp}.id = ts.#{imp_or_exp}_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    """.gsub("\n", '')
  end

  def where
    ATTRIBUTES.map { |a| send("parse_#{a.to_s}", @row[a.to_s]) }.join(' AND ')
  end

  def group_by
    "GROUP BY #{SELECT.join(',')}, #{imp_or_exp}.iso_code2"
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
    "#{imp_or_exp}.iso_code2 = '#{iso}'"
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

  def parse_origin(origin)
    "ts.country_of_origin_id IS NULL"
  end

  def imp_or_exp
    @row['applies_to_import'].present? ? 'importer' : 'exporter'
  end
end
