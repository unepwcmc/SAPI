class Trade::Grouping::TradePlusStatic < Trade::Grouping::Base

  def initialize(group, opts={})
    # exporter or importer
    @reported_by = opts[:reported_by] || 'importer'
    super(group, opts)
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

  def group_query
    columns = [@group, @attributes].flatten.compact.uniq.join(',')
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
