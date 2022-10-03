class Trade::Grouping::TradePlusStatic < Trade::Grouping::Base
  attr_reader :country_ids, :locale

  def initialize(attributes, opts={})
    # exporter or importer
    @reported_by = opts[:reported_by] || 'importer'
    @reported_by_party = opts[:reported_by_party] || true
    @country_ids = opts[:country_ids]
    @sanitised_column_names = []
    @locale = opts[:locale] || 'en'
    super(attributes, opts)
  end

  def over_time_data
    data = db.execute(over_time_query)
    response = data.map { |d| JSON.parse(d['row_to_json']) }
    sanitise_response_over_time_query(response)
  end

  def aggregated_over_time_data
    data = db.execute(aggregated_over_time_query)
    response = data.map { |d| JSON.parse(d['row_to_json']) }
    sanitise_response_aggregated_over_time_query(response)
  end

  def country_data
    db.execute(country_query)
  end

  def sanitise_response_over_time_query(response)
    response.map do |value|
      value['id'], value['name'] = 'unreported', I18n.t('tradeplus.unreported') if value['id'].nil?
    end
    response.sort_by { |i| i['name'] }
    response.partition { |value| value['id'] != 'unreported' }.reduce(:+)
  end

  def sanitise_response_aggregated_over_time_query(response)
    response.map do |value|
      value['id'], value['name'] = "reported_by_#{@reported_by}", "reported_by_#{@reported_by}" if value['id'].nil?
    end
    response.partition { |value| value['id'] != 'unreported' }.reduce(:+)
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
    'trade_plus_complete_mview'
  end

  # Allowed attributes
  ATTRIBUTES = {
    id: 'id',
    year: 'year',
    appendix: 'appendix',
    importer_iso: 'importer_iso',
    exporter_iso: 'exporter_iso',
    term_id: 'term_id',
    unit_id: 'unit_id',
    purpose_id: 'purpose_id',
    source_id: 'source_id',
    source_code: 'source_code',
    taxon_name: 'taxon_name',
    genus_name: 'genus_name',
    family_name: 'family_name',
    class_name: 'class_name',
    taxon_id: 'taxon_id',
    country_ids: 'country_ids'
  }.freeze

  def attributes
    ATTRIBUTES.merge(localize_attributes)
  end

  def localize_attributes
    hash = {}
    attrs = %w[importer exporter term unit purpose source group_name]
    attrs.each { |h| hash["#{h}_#{locale}"] = "#{h}_#{locale}" }
    hash.symbolize_keys
  end

  FILTERING_ATTRIBUTES = {
    time_range_start: 'year',
    time_range_end: 'year',
    term_ids: 'term_id',
    source_ids: 'source_id',
    purpose_ids: 'purpose_id',
    unit_id: 'unit_id',
    taxon_id: 'taxon_id',
    importer_ids: 'importer_id',
    exporter_ids: 'exporter_id',
    origin_ids: 'origin_id',
    appendices: 'appendix'
  }.freeze
  def self.filtering_attributes
    FILTERING_ATTRIBUTES.merge(localize_filtering_attributes)
  end

  def self.localize_filtering_attributes
    {
      term_names: "term_#{@locale}",
      source_names: "source_#{@locale}",
      purpose_names: "purpose_#{@locale}",
      unit_name: "unit_#{@locale}",
      taxonomic_group: "group_name_#{@locale}"
    }
  end

  DEFAULT_FILTERING_ATTRIBUTES = {
    time_range_start: 2.years.ago.year,
    time_range_end: 1.year.ago.year,
    unit_name: 'Number of specimens',
  }.freeze
  def self.default_filtering_attributes
    DEFAULT_FILTERING_ATTRIBUTES
  end

  GROUPING_ATTRIBUTES = {
    species: ['taxon_name', 'appendix', 'taxon_id'],
    taxonomy: ['']
  }.freeze
  def self.grouping_attributes
    GROUPING_ATTRIBUTES.merge(localize_grouping_attributes)
  end

  def self.localize_grouping_attributes
    {
      terms: ["term_#{@locale}", 'term_id'],
      sources: ["source_#{@locale}", 'source_id', 'source_code'],
      exporting: ["exporter_#{@locale}", 'exporter_iso'],
      importing: ["importer_#{@locale}", 'importer_iso'],
    }
  end

  def self.get_grouping_attributes(group, locale=nil)
    super(group, locale)
  end

  def child_taxa_uniquify
    return if @opts['taxon_id'].blank?
    unique_taxa = []
    taxa = @opts['taxon_id'].split(',')
    return if taxa.count < 2
    taxa.each do |taxon|
      unique_taxa.push(taxon) unless db.execute("SELECT COUNT(*) FROM all_taxon_concepts_and_ancestors_mview WHERE ancestor_taxon_concept_id IN ( #{(taxa - [taxon]).join(',')\
} ) AND taxon_concept_id = #{taxon}").values.first[0].to_i > 0
    end
    @opts['taxon_id'] = unique_taxa.join(',')
  end

  def child_taxa_join(tc_id=nil)
    child_taxa_uniquify
    return '' if @opts['taxon_id'].blank? && !tc_id

    <<-SQL
    JOIN all_taxon_concepts_and_ancestors_mview ON taxon_concept_id=taxon_id
    SQL
  end


  def child_taxa_condition
    return 'TRUE' if @opts['taxon_id'].blank?
    tc_id = @opts['taxon_id'] || tc_id
    "ancestor_taxon_concept_id IN ( #{tc_id} )"
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
      #{child_taxa_join}
      WHERE #{@condition} AND #{quantity_field} IS NOT NULL
        AND #{child_taxa_condition}
      GROUP BY #{columns}
      #{quantity_condition(quantity_field)}
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
      SELECT
        #{sanitise_column_names},
        ROUND(SUM(#{quantity_field}::FLOAT)) AS value,
        COUNT(*) OVER () AS total_count
      FROM #{shipments_table}
      #{child_taxa_join}
      WHERE #{@reported_by}_id IN (#{country_ids}) -- @reported_by = importer if importing-from chart, exporter if exporting-to chart
      AND ((reported_by_exporter = #{!reported_by_party} AND importer_id IN (#{country_ids})) OR (reported_by_exporter = #{reported_by_party} AND exporter_id IN (#{country_ids})))
      AND #{@condition} AND #{quantity_field} IS NOT NULL
      AND #{child_taxa_condition}
      GROUP BY #{columns} -- exporter if @reported_by = importer and otherway round
      #{quantity_condition(quantity_field)}
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

          SELECT year, #{sanitise_column_names}, ROUND(SUM(#{quantity_field}::FLOAT)) AS value
          FROM #{shipments_table}
          #{child_taxa_join}
          WHERE #{@condition} AND #{quantity_field} IS NOT NULL AND #{country_condition}
            AND #{child_taxa_condition}
          GROUP BY year, #{columns}
          #{quantity_condition(quantity_field)}
          ORDER BY value DESC
          #{limit}
        ) t
        GROUP BY #{sanitised_column_names}
      ) row
    SQL
  end


  # TODO refactor to merge this method and the over_time one above together
  def aggregated_over_time_query
    quantity_field = @country_ids.present? ? "#{entity_quantity}_reported_quantity" : "#{@reported_by}_reported_quantity"

    <<-SQL
      SELECT ROW_TO_JSON(row)
      FROM (
        SELECT JSON_AGG(JSON_BUILD_OBJECT('x', year, 'y', value) ORDER BY year) AS datapoints
        FROM (
          SELECT year, ROUND(SUM(#{quantity_field}::FLOAT)) AS value
          FROM #{shipments_table}
          #{child_taxa_join}
          WHERE #{@condition} AND #{quantity_field} IS NOT NULL AND #{country_condition}
            AND #{child_taxa_condition}
          GROUP BY year
          #{quantity_condition(quantity_field)}
          ORDER BY value DESC
          #{limit}
        ) t
      ) row
    SQL
  end

  def taxonomic_query(opts)
    quantity_field = @country_ids.present? ? "#{entity_quantity}_reported_quantity" : "#{@reported_by}_reported_quantity"
    taxonomic_level = opts[:taxonomic_level] || 'class'
    taxonomic_level_name = "#{taxonomic_level}_name"
    group_name = opts[:group_name]
    group_name_condition = " AND LOWER(group_name) = '#{group_name.downcase}'" if group_name
    # Exclude blanks in taxonomic level (empty strings at the selected taxonomic level)
    taxonomic_level_not_null = "#{taxonomic_level_name} IS NOT NULL"

    fill_missing_taxonomy = <<-SQL
      CASE
        -- There are still taxa with empty kingdom, so adding this condition
        -- until this is resolved at the database level.
        WHEN COALESCE(#{taxonomic_level_name}, kingdom_name, '') = '' THEN 'Unknown'
        ELSE COALESCE(#{taxonomic_level_name}, kingdom_name)
      END AS name
    SQL

    <<-SQL
      SELECT ROW_TO_JSON(row)
      FROM(
        SELECT
          NULL AS id,
          #{fill_missing_taxonomy},
          ROUND(SUM(#{quantity_field}::FLOAT)) AS value,
          #{ancestors_list(taxonomic_level)},
          COUNT(*) OVER () AS total_count
        FROM #{shipments_table}
        #{child_taxa_join}
        WHERE #{@condition} AND
        #{quantity_field} IS NOT NULL
        #{group_name_condition}
        --AND #{taxonomic_level_not_null}
        AND #{country_condition}
        AND #{child_taxa_condition}
        GROUP BY #{ancestors_list(taxonomic_level)}
        #{quantity_condition(quantity_field)}
        ORDER BY value DESC
        #{limit}
      ) row
    SQL
  end

  def ancestors_ranks(taxonomic_level)
    taxa = ['kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'taxon']
    current_idx = taxa.index(taxonomic_level) || 0
    0.upto(current_idx).map do |i|
      taxa[i]
    end
  end

  def ancestors_list(taxonomic_level)
    return 'kingdom_name' if taxonomic_level == 'kingdom'
    ancestors_ranks(taxonomic_level).map do |rank|
      "#{rank}_name"
    end.join(',')
  end

  def sanitise_column_names
    return '' if @attributes.blank?
    @attributes.map do |attribute|
      next if attribute == 'year' || attribute.nil?
      name = attribute.include?('id') ? 'id' : attribute.include?('iso') ? 'iso2' : attribute.include?('code') ? 'code' : 'name'
      @sanitised_column_names << name
      attribute = "INITCAP(#{attribute})" if attribute == 'term'
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

  def quantity_condition(field)
    "HAVING ROUND(SUM(#{field}::FLOAT)) > 0.49"
  end

  def limit
    pagination = @pagination.presence || { page: 1, per_page: @limit || 0 }
    per_page = pagination[:per_page]
    offset = (pagination[:page] - 1) * per_page

    per_page > 0 ? "LIMIT #{pagination[:per_page]} OFFSET #{offset}" : ''
  end

  # Used in the base class to skip taxon_id equality check
  # as it will be managed by the child_taxa recursive query
  def skip_taxon_id?
    @opts['taxon_id'].present?
  end
end
