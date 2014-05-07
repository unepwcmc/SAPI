class Trade::AppendixReport
  include CsvExportable

  def initialize(shipments_rel)
    @query = shipments_rel.except(:select).select([
      'trade_shipments.id', :legacy_shipment_number,
      'taxon_concepts.id', 'taxon_concepts.full_name',
      :year, 'trade_shipments.appendix',
      'ARRAY_TO_STRING(ARRAY_AGG_NOTNULL(m.appendix), \'/\')'
    ]).joins(:taxon_concept).
    joins(<<-SQL
      LEFT JOIN valid_taxon_concept_appendix_year_mview m
      ON EXTRACT(year FROM m.effective_from) <= trade_shipments.year
      AND (
        m.effective_to IS NULL
        OR EXTRACT(year FROM m.effective_to) >= trade_shipments.year
      )
      AND m.taxon_concept_id = trade_shipments.taxon_concept_id
      SQL
    ).group([
      'trade_shipments.id', :legacy_shipment_number,
      :year, 'taxon_concepts.id', 'trade_shipments.appendix'
    ])
    @diff_query = @query.having(<<-SQL
      NOT ARRAY_AGG_NOTNULL(m.appendix) @> ARRAY[trade_shipments.appendix]
      SQL
    )
  end

  def export(file_path, diff = false)
    export_to_csv(
      :query => (diff ? @diff_query : @query),
      :csv_columns => [
        'ID', 'Legacy Shipment ID', 'Taxon ID', 'Accepted Taxon', 'Year', 'Appendix', 'Auto Appendix',
      ],
      :file_path => file_path,
      :encoding => 'latin1',
      :delimiter => ';'
    )
  end

end