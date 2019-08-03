class Trade::Grouping::TradePlusStatic < Trade::Grouping::Base

  def initialize(attributes, opts={})
    # exporter or importer
    @reported_by = opts[:reported_by] || 'importer'
    super(attributes, opts)
  end

  def sources_over_time
    quantity_field = "#{@reported_by}_reported_quantity"
    query =
      <<-SQL
        SELECT source_id, source, JSON_AGG(JSON_BUILD_OBJECT('year', year, 'quantity', value)) AS values
        FROM (
          SELECT year, source_id, source, SUM(#{quantity_field}::FLOAT) AS value
          FROM #{shipments_table}
          WHERE #{@condition} AND #{quantity_field} <> 'NA'
          GROUP BY year, source_id, source
          ORDER BY value DESC
          #{limit}
        ) t
        GROUP BY source_id, source
      SQL
    db.execute(query)
  end

  private

  def shipments_table
    'trade_plus_static_complete_view'
  end

  # Allowed attributes
  ATTRIBUTES = {
    id: 'id',
    year: 'year',
    appendix: 'appendix',
    importer: 'importer',
    importer_iso: 'importer_iso',
    exporter: 'exporter',
    exporter_iso: 'exporter_iso',
    term: 'term',
    unit: 'unit',
    purpose: 'purpose',
    source: 'source',
    taxon_name: 'taxon_name',
    genus_name: 'genus_name',
    family_name: 'family_name',
    class_name: 'class_name',
    group_name: 'group_name',
    taxon_id: 'taxon_concept_id'
  }.freeze

  def attributes
    ATTRIBUTES
  end

  GROUPING_ATTRIBUTES = {
    terms: ['term', 'term_id'],
    exporting: ['exporter', 'exporter_iso', 'exporter_id'],
    importing: ['importer', 'importer_iso', 'importer_id'],
    species: ['taxon_name', 'appendix', 'taxon_concept_id'],
    taxonomy: ['']
  }.freeze
  def self.grouping_attributes
    GROUPING_ATTRIBUTES
  end

  def self.get_grouping_attributes(group)
    super(group)
  end

  def group_query
    columns = @attributes.compact.uniq.join(',')
    quantity_field = "#{@reported_by}_reported_quantity"
    <<-SQL
      SELECT
        #{columns},
        SUM(#{quantity_field}::FLOAT) AS #{quantity_field}
      FROM #{shipments_table}
      WHERE #{@condition} AND #{quantity_field} <> 'NA'
      GROUP BY #{columns}
      ORDER BY #{quantity_field} DESC
      #{limit}
    SQL
  end
end
