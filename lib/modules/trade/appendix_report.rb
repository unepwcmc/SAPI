class Trade::AppendixReport
  include CsvExportable

  def initialize(shipments_rel)
    @query = shipments_rel.except(:select).select([
      'trade_shipments.id', :legacy_shipment_number, :year,
      'trade_shipments.taxon_concept_id', 'trade_shipments.appendix',
      'm.appendix AS auto_appendix'
    ]).joins(<<-SQL
      LEFT JOIN valid_taxon_concept_appendix_year_mview m
      ON DATE_PART('year', m.effective_from) <= trade_shipments.year
      AND (
        DATE_PART('year', m.effective_to) IS NULL
        OR DATE_PART('year', m.effective_to) >= trade_shipments.year
      )
      AND m.taxon_concept_id = trade_shipments.taxon_concept_id
      SQL
    ).uniq

    @query = Trade::Shipment.from("(#{@query.to_sql}) s").
    select([
      's.id', :legacy_shipment_number, :taxon_concept_id,
      :full_name, :year, :appendix,
      'ARRAY_TO_STRING(ARRAY_AGG_NOTNULL(auto_appendix ORDER BY auto_appendix), \'/\')'
    ]).
    joins('JOIN taxon_concepts ON s.taxon_concept_id = taxon_concepts.id').
    group([
      's.id', :legacy_shipment_number, :taxon_concept_id,
      'taxon_concepts.full_name', :year, :appendix
    ]).order([:full_name, :year, :appendix, 's.id'])

    @diff_query = @query.having(<<-SQL
      NOT ARRAY_AGG_NOTNULL(auto_appendix) @> ARRAY[appendix]
      SQL
    )
  end

  def export(file_path, diff = false)
    export_to_csv(
      :query => (diff ? @diff_query : @query),
      :csv_columns => [
        'ID', 'Legacy Shipment ID', 'Taxon ID', 'Accepted Taxon', 'Year', 'Appendix', 'Auto Appendix'
      ],
      :file_path => file_path,
      :encoding => 'latin1',
      :delimiter => ';'
    )
  end

end
