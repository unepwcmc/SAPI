class Trade::Grouping::TradePlusStatic < Trade::Grouping::Base

  def initialize(attributes, opts={})
    # exporter or importer
    @reported_by = opts[:reported_by] || 'importer'
    @reported_by_party = opts[:reported_by_party] || true
    @country_id = opts[:country_id]
    @sanitised_column_names = []
    super(attributes, opts)
  end

  def over_time_data
    data = db.execute(over_time_query)
    response = data.map { |d| JSON.parse(d['row_to_json']) }
    sanitise_response_over_time_query(response)
  end

  def country_data
    data = db.execute(country_query)
    data
  end

  def sanitise_response_over_time_query(response)
    response.map do |value|
      value['id'], value['name'] = 'unreported', 'Unreported' if value['id'].nil?
    end
    response.sort_by { |i| i['name'] }
  end

  def taxonomic_grouping(opts={})
    data = db.execute(taxonomic_query(opts))
    data.map { |d| JSON.parse(d['row_to_json']) }
  end

  #TODO remove and generalize the one already in place
  def country_taxonomic_grouping(opts={})
    data = db.execute(country_taxonomic_query(opts))
    data.map { |d| JSON.parse(d['row_to_json']) }
  end

  # TODO better define hash key
  def json_by_attribute(data, opts={})
    key = data.fields.first
    hash = { "#{key}" => [] }
    data.each do |d|
      hash[key] << d
    end
    hash[key]
  end

  private

  def shipments_table
    #'trade_plus_static_complete_view'
    'trade_plus_complete_mview'
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
    taxon_id: 'taxon_id',
    country_id: 'country_id'
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
    origin: 'origin_iso',
    appendices: 'appendix',
    taxonomic_group: 'group_name'
  }.freeze
  def self.filtering_attributes
    FILTERING_ATTRIBUTES
  end

  DEFAULT_FILTERING_ATTRIBUTES = {
    time_range_start: 2.years.ago.year,
    time_range_end: 1.year.ago.year,
    unit_name: 'Number of Items',
  }.freeze
  def self.default_filtering_attributes
    DEFAULT_FILTERING_ATTRIBUTES
  end

  GROUPING_ATTRIBUTES = {
    terms: ['term', 'term_id'],
    sources: ['source', 'source_id'],
    exporting: ['exporter', 'exporter_iso'],
    importing: ['importer', 'importer_iso'],
    species: ['taxon_name', 'appendix', 'taxon_id'],
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
        ROUND(SUM(#{quantity_field}::FLOAT)) AS value,
        COUNT(*) OVER () AS total_count
      FROM #{shipments_table}
      WHERE #{@condition} AND #{quantity_field} IS NOT NULL
      GROUP BY #{columns}
      ORDER BY value DESC
      #{limit}
    SQL
  end

  def country_query
    # This should be true for reported_by_party tab, false for the reported_by_partners
    reported_by_party = sanitise_boolean
    country_id = @country_id
    # TODO Rename @reported_by as this is related to import-from and export-to charts here rather than importer/exporter tabs in other pages
    # As the quantity field is strictly related to the reported_by_exporter value this should change accordingly with the tabs/chart combination:
    # party + importing = importer_reported_quantity
    # party + exporting = exporter_reported_quantity
    # partners + importing = exporter_reported_quantity
    # partners + exporting = importer_reported_quantity
    entity = if (reported_by_party && (@reported_by == 'importer')) || (!reported_by_party && (@reported_by == 'exporter'))
                 'importer'
               elsif (reported_by_party && (@reported_by == 'exporter')) || (!reported_by_party && (@reported_by == 'importer'))
                 'exporter'
               end
    quantity_field = "#{entity}_reported_quantity"
    columns = @attributes.compact.uniq.join(',')
    <<-SQL
      SELECT
        #{sanitise_column_names},
        ROUND(SUM(#{quantity_field}::FLOAT)) AS value,
        COUNT(*) OVER () AS total_count
      FROM #{shipments_table}
      WHERE #{@reported_by}_id = #{country_id} -- @reported_by = importer if importing-from chart, exporter if exporting-to chart
      AND ((reported_by_exporter = #{!reported_by_party} AND importer_id = #{country_id}) OR (reported_by_exporter = #{reported_by_party} AND exporter_id = #{country_id}))
      AND #{@condition} AND #{quantity_field} IS NOT NULL
      GROUP BY #{columns} -- exporter if @reported_by = importer and otherway round
      ORDER BY value DESC
      #{limit}
    SQL
  end

  #TODO refactor avoiding variable repetition
  def over_time_query
    quantity_field = @country_id.present? ? "#{entity_quantity}_reported_quantity" : "#{@reported_by}_reported_quantity"
    columns = @attributes.compact.uniq.join(',')
    # @sanitised_column_names value is assigned in the super class
    # while the @query variable is assigned as well because of the grouped_query
    sanitised_column_names = @sanitised_column_names.compact.uniq.join(',')

    country_id = @country_id
    reported_by_party = sanitise_boolean
    country_over_time = "AND #{@reported_by}_id = #{country_id} AND ((reported_by_exporter = #{!reported_by_party} AND importer_id = #{country_id}) OR (reported_by_exporter = #{reported_by_party} AND exporter_id = #{country_id}))" if @country_id

    <<-SQL
      SELECT ROW_TO_JSON(row)
      FROM (
        SELECT #{sanitised_column_names}, JSON_AGG(JSON_BUILD_OBJECT('x', year, 'y', value) ORDER BY year) AS datapoints
        FROM (
          SELECT year, #{sanitise_column_names}, ROUND(SUM(#{quantity_field}::FLOAT)) AS value
          FROM #{shipments_table}
          WHERE #{@condition} AND #{quantity_field} IS NOT NULL #{country_over_time}
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
          ROUND(SUM(#{quantity_field}::FLOAT)) AS value,
          COUNT(*) OVER () AS total_count
        FROM #{shipments_table}
        WHERE #{@condition} AND #{quantity_field} IS NOT NULL #{group_name_condition}
        GROUP BY #{taxonomic_level_name}
        ORDER BY value DESC
        #{limit}
      ) row
    SQL
  end

  #TODO remove and generalize the one already in place
  def country_taxonomic_query(opts)
    reported_by_party = sanitise_boolean
    country_id = @country_id
    entity = if (reported_by_party && (@reported_by == 'importer')) || (!reported_by_party && (@reported_by == 'exporter'))
                 'importer'
               elsif (reported_by_party && (@reported_by == 'exporter')) || (!reported_by_party && (@reported_by == 'importer'))
                 'exporter'
               end
    quantity_field = "#{entity}_reported_quantity"
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
          ROUND(SUM(#{quantity_field}::FLOAT)) AS value,
          COUNT(*) OVER () AS total_count
        FROM #{shipments_table}
        WHERE #{@condition} AND #{quantity_field} IS NOT NULL #{group_name_condition}
        AND #{@reported_by}_id = #{country_id} -- @reported_by = importer if importing-from chart, exporter if exporting-to chart
        AND ((reported_by_exporter = #{!reported_by_party} AND importer_id = #{country_id}) OR (reported_by_exporter = #{reported_by_party} AND exporter_id = #{country_id}))
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

  def sanitise_boolean
    return true if !['true', 'false'].include? @reported_by_party
    @reported_by_party == 'true'
  end

  def entity_quantity
    reported_by_party = sanitise_boolean
    if (reported_by_party && (@reported_by == 'importer')) || (!reported_by_party && (@reported_by == 'exporter'))
      'importer'
    elsif (reported_by_party && (@reported_by == 'exporter')) || (!reported_by_party && (@reported_by == 'importer'))
      'exporter'
    end
  end

  def limit
    pagination = @pagination.presence || { page: 1, per_page: @limit || 0 }
    per_page = pagination[:per_page]
    offset = (pagination[:page] - 1) * per_page

    per_page > 0 ? "LIMIT #{pagination[:per_page]} OFFSET #{offset}" : ''
  end
end
