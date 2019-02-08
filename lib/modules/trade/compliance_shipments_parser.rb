class Trade::ComplianceShipmentsParser

  ATTRIBUTES = [
    :start_date, :end_date, :taxon_concept_id, :iso_code2,
    :unit, :term, :source, :purpose, :origin
  ]

  protected

  def parse_start_date(date)
    year = date.split('/').last.to_i
    "ts.year >= #{year}"
  end

  def parse_end_date(date)
    year = date.blank? || date.upcase == 'PRESENT' ? Date.today.year : date.split('/').last.to_i
    "ts.year <= #{year}"
  end

  def parse_iso_code2(iso)
    return 'TRUE' if iso.blank? || iso.upcase == 'ALL'
    "#{imp_or_exp_country}.iso_code2 = '#{iso}'"
  end

  def parse_taxon_concept_id(tc)
    return 'TRUE' if tc.blank? || tc.upcase == 'ALL'
    "ts.taxon_concept_id = #{tc}"
  end

  def parse_unit(unit)
    parse_trade_code(unit, 'units')
  end

  def parse_term(term)
    parse_trade_code(term, 'terms')
  end

  def parse_purpose(purpose)
    parse_trade_code(purpose, 'purposes')
  end

  def parse_source(source)
    parse_trade_code(source, 'sources')
  end

  def parse_trade_code(code, type)
    #Return TRUE to prevent empty conditions and a malformed query
    return 'TRUE' if code.blank? || code.upcase == 'ALL'

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
