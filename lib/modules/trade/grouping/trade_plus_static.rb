class Trade::Grouping::TradePlusStatic < Trade::Grouping::Base

  # Allowed attributes
  # TODO needs to be updated
  ATTRIBUTES = {
    id: 'id',
    year: 'year',
    appendix: 'appendix',
    importer: 'importer',
    #importer_iso: 'importer_iso',
    exporter: 'exporter',
    #exporter_iso: 'exporter_iso',
    term: 'term',
    unit: 'unit',
    purpose: 'purpose',
    source: 'source',
    taxon_name: 'taxon_name',
    genus_name: 'genus_name',
    family_name: 'family_name',
    class_name: 'class_name',
    taxon_id: 'taxon_concept_id'
  }

  GROUPING_ATTRIBUTES = {
    category: ['year'],
    commodity: ['term', 'term_id'],
    exporting: ['exporter', 'exporter_iso', 'exporter_id'],
    importing: ['importer', 'importer_iso', 'importer_id'],
    species: ['taxon_name', 'appendix', 'taxon_id'],
    taxonomy: [''],
  }

  def initialize(group, opts={})
    super(group, opts)
  end

  def group_query
    columns = [@group, @attributes].flatten.compact.uniq.join(',')
    <<-SQL
      SELECT #{columns}, COUNT(*) AS cnt
      FROM #{shipments_table}
      WHERE #{@condition}
      GROUP BY #{columns}
      ORDER BY cnt DESC
      #{limit}
    SQL
  end

  private

  def shipments_table
    'trade_plus_static_complete_view'
  end

end
