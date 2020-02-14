class Trade::Grouping::TradePlusStatic < Trade::Grouping::Base
  attr_reader :country_ids

  def initialize(attributes, opts={})
    # exporter or importer
    @reported_by = opts[:reported_by] || 'importer'
    @reported_by_party = opts[:reported_by_party] || true
    @country_ids = opts[:country_ids]
    @sanitised_column_names = []
    super(attributes, opts)
  end

  def over_time_data
    data = db.execute(over_time_query)
    response = data.map { |d| JSON.parse(d['row_to_json']) }
    sanitise_response_over_time_query(response)
  end

  def country_data
    db.execute(country_query)
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
    country_ids: 'country_ids'
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
    importer_ids: 'importer_id',
    exporter_ids: 'exporter_id',
    origin_ids: 'origin_id',
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

  def child_taxa_query(tc_id=nil)
    return '' if @opts['taxon_id'].blank? && !tc_id
    tc_id = @opts['taxon_id'] || tc_id
    <<-SQL
      WITH RECURSIVE selected_taxa AS (
        SELECT UNNEST(ARRAY[#{tc_id}]) AS id
      ),
      child_taxa AS (
        SELECT id
        FROM selected_taxa

        UNION ALL

        SELECT tc.id
        FROM taxon_concepts tc
        JOIN child_taxa ON child_taxa.id = tc.parent_id
      )
    SQL
  end

  def child_taxa_condition
    return 'TRUE' if @opts['taxon_id'].blank?
    "taxon_id IN ( SELECT DISTINCT(id) FROM child_taxa )"
  end

  def group_query
    columns = @attributes.compact.uniq.join(',')
    quantity_field = "#{@reported_by}_reported_quantity"
    <<-SQL
      #{child_taxa_query}
      SELECT
        #{sanitise_column_names},
        ROUND(SUM(#{quantity_field}::FLOAT)) AS value,
        COUNT(*) OVER () AS total_count
      FROM #{shipments_table}
      WHERE #{@condition} AND #{quantity_field} IS NOT NULL
        AND #{child_taxa_condition}
      GROUP BY #{columns}
      ORDER BY value DESC
      #{limit}
    SQL
  end

  def country_query
    # This should be true for reported_by_party tab, false for the reported_by_partners
    reported_by_party = sanitise_boolean(@reported_by_party)
    # TODO Rename @reported_by as this is related to import-from and export-to charts here rather than importer/exporter tabs in other pages
    # As the quantity field is strictly related to the reported_by_exporter value this should change accordingly with the tabs/chart combination:
    # party + importing = importer_reported_quantity
    # party + exporting = exporter_reported_quantity
    # partners + importing = exporter_reported_quantity
    # partners + exporting = importer_reported_quantity
    quantity_field = "#{entity_quantity}_reported_quantity"
    columns = @attributes.compact.uniq.join(',')
    <<-SQL
      #{child_taxa_query}
      SELECT
        #{sanitise_column_names},
        ROUND(SUM(#{quantity_field}::FLOAT)) AS value,
        COUNT(*) OVER () AS total_count
      FROM #{shipments_table}
      WHERE #{@reported_by}_id IN (#{country_ids}) -- @reported_by = importer if importing-from chart, exporter if exporting-to chart
      AND ((reported_by_exporter = #{!reported_by_party} AND importer_id IN (#{country_ids})) OR (reported_by_exporter = #{reported_by_party} AND exporter_id IN (#{country_ids})))
      AND #{@condition} AND #{quantity_field} IS NOT NULL
      AND #{child_taxa_condition}
      GROUP BY #{columns} -- exporter if @reported_by = importer and otherway round
      ORDER BY value DESC
      #{limit}
    SQL
  end

  def over_time_query
    quantity_field = @country_ids.present? ? "#{entity_quantity}_reported_quantity" : "#{@reported_by}_reported_quantity"
    columns = @attributes.compact.uniq.join(',')
    # @sanitised_column_names value is assigned in the super class
    # while the @query variable is assigned as well because of the grouped_query
    sanitised_column_names = @sanitised_column_names.compact.uniq.join(',')

    <<-SQL
      SELECT ROW_TO_JSON(row)
      FROM (
        SELECT #{sanitised_column_names}, JSON_AGG(JSON_BUILD_OBJECT('x', year, 'y', value) ORDER BY year) AS datapoints
        FROM (
          #{child_taxa_query}
          SELECT year, #{sanitise_column_names}, ROUND(SUM(#{quantity_field}::FLOAT)) AS value
          FROM #{shipments_table}
          WHERE #{@condition} AND #{quantity_field} IS NOT NULL AND #{country_condition}
            AND #{child_taxa_condition}
          GROUP BY year, #{columns}
          ORDER BY value DESC
          #{limit}
        ) t
        GROUP BY #{sanitised_column_names}
      ) row
    SQL
  end

  def taxonomic_query(opts)
    quantity_field = @country_ids.present? ? "#{entity_quantity}_reported_quantity" : "#{@reported_by}_reported_quantity"
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
        #{child_taxa_query}
        SELECT
          NULL AS id,
          #{['phylum', 'class'].include?(taxonomic_level) ? check_for_plants : "#{taxonomic_level_name} AS name," }
          ROUND(SUM(#{quantity_field}::FLOAT)) AS value,
          COUNT(*) OVER () AS total_count
        FROM #{shipments_table}
        WHERE #{@condition} AND #{quantity_field} IS NOT NULL #{group_name_condition}
        AND #{country_condition}
        AND #{child_taxa_condition}
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

  def sanitise_boolean(bool)
    return true unless ['true', 'false'].include? bool
    bool == 'true'
  end

  def entity_quantity
    reported_by_party = sanitise_boolean(@reported_by_party)
    if (reported_by_party && (@reported_by == 'importer')) || (!reported_by_party && (@reported_by == 'exporter'))
      'importer'
    elsif (reported_by_party && (@reported_by == 'exporter')) || (!reported_by_party && (@reported_by == 'importer'))
      'exporter'
    end
  end

  def country_condition
    return 'TRUE' unless @country_ids
    reported_by_party = sanitise_boolean(@reported_by_party)
    "#{@reported_by}_id IN (#{country_ids}) AND ((reported_by_exporter = #{!reported_by_party} AND importer_id IN (#{country_ids})) OR (reported_by_exporter = #{reported_by_party} AND exporter_id IN (#{country_ids})))"
  end

  def limit
    pagination = @pagination.presence || { page: 1, per_page: @limit || 0 }
    per_page = pagination[:per_page]
    offset = (pagination[:page] - 1) * per_page

    per_page > 0 ? "LIMIT #{pagination[:per_page]} OFFSET #{offset}" : ''
  end
end
