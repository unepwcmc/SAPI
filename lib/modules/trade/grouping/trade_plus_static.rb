class Trade::Grouping::TradePlusStatic < Trade::Grouping::Base

  def initialize(attributes, opts={})
    # exporter or importer
    @reported_by = opts[:reported_by] || 'importer'
    @sanitised_column_names = []
    super(attributes, opts)
  end

  def over_time_data
    data = db.execute(over_time_query)
    data.map { |d| JSON.parse(d['row_to_json']) }
  end

  def taxonomic_grouping(opts={})
    data = db.execute(taxonomic_query(opts))
    data.map { |d| JSON.parse(d['row_to_json']) }
  end

  # TODO better define hash key
  def json_by_attribute(data, opts={})
    key = data.fields.first
    hash = { "#{key}" => [] }
    data.each do |d|
      hash[key] << d
    end
    hash[key][0..4]
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
    term_id: 'term_id',
    unit: 'unit',
    unit_id: 'unit_id',
    purpose: 'purpose',
    purpose_id: 'purpose_id',
    source: 'source',
    source_id: 'source_id',
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

  FILTERING_ATTRIBUTES = {
    time_range_start: 'year',
    time_range_end: 'year',
    term_names: 'term',
    term_ids: 'term_id',
    source_names: 'source',
    source_ids: 'source_id',
    purpose_names: 'purpose',
    purpose_ids: 'purpose_id',
    unit_name: 'unit',
    unit_id: 'unit_id',
    taxon_id: 'taxon_id',
    importer: 'importer_iso',
    exporter: 'exporter_iso',
    origin: 'origin_iso'
  }.freeze
  def self.filtering_attributes
    FILTERING_ATTRIBUTES
  end

  DEFAULT_FILTERING_ATTRIBUTES = {
    time_range_start: 2.years.ago.year,
    time_range_end: 1.year.ago.year
  }.freeze
  def self.default_filtering_attributes
    DEFAULT_FILTERING_ATTRIBUTES
  end

  GROUPING_ATTRIBUTES = {
    terms: ['term', 'term_id'],
    sources: ['source', 'source_id'],
    exporting: ['exporter', 'exporter_iso'],
    importing: ['importer', 'importer_iso'],
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
        #{sanitise_column_names},
        SUM(#{quantity_field}::FLOAT) AS value
      FROM #{shipments_table}
      WHERE #{@condition} AND #{quantity_field} <> 'NA'
      GROUP BY #{columns}
      ORDER BY value DESC
      #{limit}
    SQL
  end

  def over_time_query
    quantity_field = "#{@reported_by}_reported_quantity"
    columns = @attributes.compact.uniq.join(',')
    sanitised_column_names = @sanitised_column_names.compact.uniq.join(',')

    <<-SQL
      SELECT ROW_TO_JSON(row)
      FROM (
        SELECT #{sanitised_column_names}, JSON_AGG(JSON_BUILD_OBJECT('x', year, 'y', value)) AS datapoints
        FROM (
          SELECT year, #{sanitise_column_names}, SUM(#{quantity_field}::FLOAT) AS value
          FROM #{shipments_table}
          WHERE #{@condition} AND #{quantity_field} <> 'NA'
          GROUP BY year, #{columns}
          ORDER BY value DESC
          #{limit}
        ) t
        GROUP BY #{sanitised_column_names}
      ) row
    SQL
  end

  def taxonomic_query(opts)
    quantity_field = "#{@reported_by}_reported_quantity"
    taxonomic_level = opts[:taxonomic_level] || 'class'
    taxonomic_level_name = "#{taxonomic_level}_name"
    group_name = opts[:group_name]
    group_name_condition = " AND LOWER(group_name) = '#{group_name.downcase}'" if group_name

    check_for_plants = <<-SQL
      CASE
        WHEN COALESCE(#{taxonomic_level_name}, '') = '' THEN 'Plants'
        ELSE #{taxonomic_level_name}
      END AS name,
    SQL

    <<-SQL
      SELECT ROW_TO_JSON(row)
      FROM(
        SELECT
          NULL AS id,
          #{['phylum', 'class'].include?(taxonomic_level) ? check_for_plants : "#{taxonomic_level_name} AS name," }
          SUM(#{quantity_field}::FLOAT) AS value
        FROM #{shipments_table}
        WHERE #{@condition} AND #{quantity_field} <> 'NA' #{group_name_condition}
        GROUP BY #{taxonomic_level_name}
        ORDER BY value DESC
        #{limit}
      ) row
    SQL
  end

  def sanitise_column_names
    return '' if @attributes.blank?
    @attributes.map do |attribute|
      next if attribute == 'year' || attribute.nil?
      name = attribute.include?('id') ? 'id' : attribute.include?('iso') ? 'iso2' : 'name'
      @sanitised_column_names << name
      "#{attribute} AS #{name}"
    end.compact.uniq.join(',')
  end
end
