class Trade::ReservationsShipmentsParser

  ATTRIBUTES = [:start_date, :end_date, :taxon_concept_id, :iso_code2]

  protected

  def parse_start_date(date)
    year = date.split('/').last.to_i
    "ts.year > #{year}"
  end

  def parse_end_date(date)
    year = date.blank? ? Date.today.year : date.split('/').last.to_i
    "ts.year < #{year}"
  end

  def parse_iso_code2(iso)
    "((ts.reported_by_exporter IS TRUE AND exporters.iso_code2 = '#{iso}')
    OR (ts.reported_by_exporter IS FALSE AND importers.iso_code2 = '#{iso}'))"
  end

  def parse_taxon_concept_id(tc)
    "ts.taxon_concept_id = #{tc}"
  end
end
