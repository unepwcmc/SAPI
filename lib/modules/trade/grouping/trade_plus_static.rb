class Trade::Grouping::TradePlusStatic < Trade::Grouping::Base
  attr_reader :country_ids, :locale

  def initialize(opts = {})
    # exporter or importer # TODO: FIXME BAD BAD MORE INJECTIONS HERE
    @reported_by = opts[:reported_by] || 'importer'
    @reported_by_party = opts[:reported_by_party] || true
    @country_ids = opts[:country_ids]

    super
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

    response.sort_by { |i| i['name'] || '' }

    response.partition { |value| value['id'] != 'unreported' }.reduce(:+)
  end

  def sanitise_response_aggregated_over_time_query(response)
    response.map do |value|
      value['id'], value['name'] = "reported_by_#{@reported_by}", "reported_by_#{@reported_by}" if value['id'].nil?
    end

    response.partition { |value| value['id'] != 'unreported' }.reduce(:+)
  end

  def taxonomic_grouping(opts = {})
    data = db.execute(taxonomic_query(opts))

    data.map { |d| JSON.parse(d['row_to_json']) }
  end

  # TODO better define hash key
  def json_by_attribute(data, opts = {})
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
    term_code: 'term_code',
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

  def filterable_attributes
    # TODO: consider whether some columns take only some of these.
    null_values = [ 'unreported', 'direct', 'items' ]

    # Note: defaults never worked correctly as with_defaults was not respected,
    # so removed them as described in:
    #
    # https://github.com/unepwcmc/SAPI/pull/1067#discussion_r3821170905
    {
      time_range_start: {
        column_name: 'year',
        operator: :gteq,
        type: :integer
        # default: 2.years.ago.year
      },
      time_range_end: {
        column_name: 'year',
        operator: :lteq,
        type: :integer
        # default: 1.year.ago.year
      },
      term_ids: {
        column_name: 'term_id',
        null_values: null_values,
        multiple: true,
        type: :integer
      },
      source_ids: {
        column_name: 'source_id',
        null_values: null_values,
        multiple: true,
        type: :integer
      },
      purpose_ids: {
        column_name: 'purpose_id',
        null_values: null_values,
        multiple: true,
        type: :integer
      },
      unit_id: {
        column_name: 'unit_id',
        null_values: null_values,
        multiple: true,
        type: :integer
      },
      taxon_id: {
        column_name: 'taxon_id',
        null_values: null_values,
        multiple: true,
        type: :integer
      },
      importer_ids: {
        column_name: 'importer_id',
        null_values: null_values,
        multiple: true,
        type: :integer
      },
      exporter_ids: {
        column_name: 'exporter_id',
        null_values: null_values,
        multiple: true,
        type: :integer
      },
      origin_ids: {
        column_name: 'origin_id',
        null_values: null_values,
        multiple: true,
        type: :integer
      },
      appendices: {
        column_name: 'appendix',
        multiple: true,
        type: :text
      },
      term_names: {
        column_name: "term_#{@locale}",
        multiple: true,
        transform: :downcase,
        type: :text
      },
      source_names: {
        column_name: "source_#{@locale}",
        multiple: true,
        transform: :downcase,
        type: :text
      },
      purpose_names: {
        column_name: "purpose_#{@locale}",
        multiple: true,
        transform: :downcase,
        type: :text
      },
      unit_name: {
        column_name: "unit_#{@locale}",
        multiple: true,
        transform: :downcase,
        type: :text
        # default: 'Number of specimens'
      },
      taxonomic_group: {
        column_name: 'group_code', # group_code is indexed
        multiple: true,
        transform: :downcase,
        type: :text
      }
    }
  end

  def self.build_grouping_attributes_by_group(locale_arg)
    {
      species: [ 'taxon_name', 'appendix', 'taxon_id' ],
      taxonomy: [],
      terms: [ "term_#{locale_arg}", 'term_id', 'term_code' ],
      sources: [ "source_#{locale_arg}", 'source_id', 'source_code' ],
      exporting: [ "exporter_#{locale_arg}", 'exporter_iso' ],
      importing: [ "importer_#{locale_arg}", 'importer_iso' ]
    }
  end

  def child_taxa_uniquify
    return if @opts['taxon_id'].blank?

    unique_taxa = []
    taxa = @opts['taxon_id'].split(',').map(&:to_i)
    return if taxa.count < 2

    taxa.each do |taxon|
      unique_taxa.push(taxon) unless db.execute(
        <<-SQL.squish
          SELECT COUNT(*)
          FROM all_taxon_concepts_and_ancestors_mview
          WHERE ancestor_taxon_concept_id IN (#{(taxa - [ taxon.to_i ]).join(',')})
            AND taxon_concept_id = #{taxon.to_i}
        SQL
      ).values.first[0].to_i > 0
    end

    @opts['taxon_id'] = unique_taxa.join(',')
  end

  def child_taxa_join(tc_id = nil)
    child_taxa_uniquify

    return '' if @opts['taxon_id'].blank? && !tc_id

    <<-SQL.squish
      JOIN all_taxon_concepts_and_ancestors_mview
        ON taxon_concept_id = taxon_id
    SQL
  end

  def child_taxa_condition
    return 'TRUE' if @opts['taxon_id'].blank?

    tc_id = @opts['taxon_id'] || tc_id
    "ancestor_taxon_concept_id IN ( #{tc_id} )"
  end

  def group_query
    columns_for_select_sql = columns_with_aliases_sql
    group_by_column_names_sql = sanitised_columns_sql

    # Apparently this is ok
    # if columns_for_select_sql.blank?
    #   raise(ArgumentError, 'Missing list of columns to select')
    # end

    if group_by_column_names_sql.blank?
      raise(ArgumentError, 'Missing list of columns to group by')
    end

    quantity_field = "#{@reported_by}_reported_quantity"

    <<-SQL.squish
      SELECT
        #{columns_for_select_sql&.+ ','}
        ROUND(SUM(#{db.quote_column_name quantity_field}::FLOAT)) AS value,
        COUNT(*) OVER () AS total_count
      FROM
        #{shipments_table}
        #{child_taxa_join}
      WHERE #{@condition} AND #{db.quote_column_name quantity_field} IS NOT NULL
        AND #{child_taxa_condition}
      GROUP BY #{group_by_column_names_sql}
      #{having_quantity_sql(quantity_field)}
      ORDER BY value DESC
      #{limit}
    SQL
  end

  def country_query
    # TODO Rename @reported_by as this is related to import-from and export-to charts here rather than importer/exporter tabs in other pages
    # As the quantity field is strictly related to the reported_by_exporter value this should change accordingly with the tabs/chart combination:
    # party + importing = importer_reported_quantity
    # party + exporting = exporter_reported_quantity
    # partners + importing = exporter_reported_quantity
    # partners + exporting = importer_reported_quantity
    quantity_field = "#{entity_quantity}_reported_quantity"

    columns_for_select_sql = columns_with_aliases_sql
    group_by_column_names_sql = sanitised_columns_sql

    if columns_for_select_sql.blank?
      raise(ArgumentError, 'Missing list of columns')
    end

    if group_by_column_names_sql.blank?
      raise(ArgumentError, 'Missing list of columns to group by')
    end

    <<-SQL
      SELECT
        #{columns_for_select_sql&.+ ','}
        ROUND(SUM(#{db.quote_column_name quantity_field}::FLOAT)) AS value,
        COUNT(*) OVER () AS total_count
      FROM #{shipments_table}
      #{child_taxa_join}
      WHERE #{country_condition}
        AND #{@condition} AND #{db.quote_column_name quantity_field} IS NOT NULL
        AND #{child_taxa_condition}
      GROUP BY #{group_by_column_names_sql} -- exporter if @reported_by = importer and otherway round
      #{having_quantity_sql(quantity_field)}
      ORDER BY value DESC
      #{limit}
    SQL
  end

  def over_time_query
    quantity_field = @country_ids.present? ? "#{entity_quantity}_reported_quantity" : "#{@reported_by}_reported_quantity"
    columns_for_select_sql = columns_with_aliases_sql
    group_by_column_names_sql = sanitised_columns_sql
    outer_group_by_column_names_sql = columns_aliases_only_sql

    if columns_for_select_sql.blank?
      raise(ArgumentError, 'Missing list of columns')
    end

    if group_by_column_names_sql.blank? || outer_group_by_column_names_sql.blank?
      raise(ArgumentError, 'Missing list of columns to group by')
    end

    <<-SQL.squish
      SELECT ROW_TO_JSON(row)
      FROM (
        SELECT
          #{outer_group_by_column_names_sql},
          JSON_AGG(JSON_BUILD_OBJECT('x', year, 'y', value) ORDER BY year) AS datapoints
        FROM (
          SELECT
            year,
            #{columns_for_select_sql&.+ ','}
            ROUND(SUM(#{db.quote_column_name quantity_field}::FLOAT)) AS value
          FROM #{shipments_table}
          #{child_taxa_join}
          WHERE #{@condition}
            AND #{db.quote_column_name quantity_field} IS NOT NULL
            AND #{country_condition}
            AND #{child_taxa_condition}
          GROUP BY year, #{group_by_column_names_sql}
          #{having_quantity_sql(quantity_field)}
          ORDER BY value DESC
          #{limit}
        ) t
        GROUP BY #{outer_group_by_column_names_sql}
      ) row
    SQL
  end


  # TODO refactor to merge this method and the over_time one above together
  def aggregated_over_time_query
    quantity_field = @country_ids.present? ? "#{entity_quantity}_reported_quantity" : "#{@reported_by}_reported_quantity"

    <<-SQL.squish
      SELECT ROW_TO_JSON(row)
      FROM (
        SELECT JSON_AGG(JSON_BUILD_OBJECT('x', year, 'y', value) ORDER BY year) AS datapoints
        FROM (
          SELECT year, ROUND(SUM(#{db.quote_column_name quantity_field}::FLOAT)) AS value
          FROM #{shipments_table}
          #{child_taxa_join}
          WHERE #{@condition} AND #{db.quote_column_name quantity_field} IS NOT NULL AND #{country_condition}
            AND #{child_taxa_condition}
          GROUP BY year
          #{having_quantity_sql(quantity_field)}
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

    group_name_condition = " AND LOWER(group_name) = #{db.quote group_name.downcase}" if group_name
    # Exclude blanks in taxonomic level (empty strings at the selected taxonomic level)
    # taxonomic_level_not_null = "#{taxonomic_level_name} IS NOT NULL"

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
          ROUND(SUM(#{db.quote_column_name quantity_field}::FLOAT)) AS value,
          #{ancestor_column_list_sql(taxonomic_level)},
          COUNT(*) OVER () AS total_count
        FROM #{shipments_table}
        #{child_taxa_join}
        WHERE #{@condition} AND
        #{db.quote_column_name quantity_field} IS NOT NULL
        #{group_name_condition}
        --AND taxonomic_level_not_null
        AND #{country_condition}
        AND #{child_taxa_condition}
        GROUP BY #{ancestor_column_list_sql(taxonomic_level)}
        #{having_quantity_sql(quantity_field)}
        ORDER BY value DESC
        #{limit}
      ) AS row
    SQL
  end

  def ancestors_ranks(taxonomic_level)
    taxa = [ 'kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'taxon' ]
    current_idx = taxa.index(taxonomic_level) || 0

    0.upto(current_idx).map do |i|
      taxa[i]
    end
  end

  def ancestor_column_list_sql(taxonomic_level)
    return 'kingdom_name' if taxonomic_level == 'kingdom'

    ancestors_ranks(taxonomic_level).map do |rank|
      db.quote_column_name "#{rank}_name"
    end.join(', ')
  end

  def columns_with_aliases(attribute_names = @attributes)
    return [] if attribute_names.blank?

    attribute_names.compact.uniq.map do |attribute|
      next if attribute == 'year'

      column_alias =
        if attribute.include?('id')
          'id'
        elsif attribute.include?('iso')
          'iso2'
        elsif attribute.include?('code')
          'code'
        elsif [
          "exporter_#{@locale}",
          "importer_#{@locale}",
          "term_#{@locale}",
          "source_#{@locale}"
        ].include?(attribute)
          'name'
        else
          attribute
        end

      column_expression =
        if attribute == "term_#{@locale}"
          <<-SQL.squish
            UPPER(SUBSTRING(#{db.quote_column_name attribute} FROM 1 FOR 1)) ||
            LOWER(SUBSTRING(#{db.quote_column_name attribute} FROM 2))
          SQL
        else
          db.quote_column_name attribute
        end

      { column_expression:, column_alias: }
    end.compact
  end

  def columns_with_aliases_sql(attribute_names = @attributes)
    columns_with_aliases(attribute_names).map do |col|
      "#{col[:column_expression]} AS #{db.quote_column_name col[:column_alias]}"
    end.join(', ').presence
  end

  def columns_aliases_only_sql(attribute_names = @attributes)
    columns_with_aliases(attribute_names).map do |col|
      db.quote_column_name col[:column_alias]
    end.join(', ').presence
  end

  ##
  # returns `false` if the original value is the string `'false'`; otherwise
  # returns `true.
  def sanitise_boolean(bool)
    return true unless [ 'true', 'false' ].include? bool

    bool == 'true'
  end

  ##
  # returns string `'importer'` or `'exporter'`
  def entity_quantity
    # This should be true for reported_by_party tab, false for the reported_by_partners
    reported_by_party = sanitise_boolean(@reported_by_party)

    if (reported_by_party && (@reported_by == 'importer')) || (!reported_by_party && (@reported_by == 'exporter'))
      'importer'
    elsif (reported_by_party && (@reported_by == 'exporter')) || (!reported_by_party && (@reported_by == 'importer'))
      'exporter'
    end
  end

  def country_condition
    country_ids_sql = Array.wrap(@country_ids.presence || [])&.compact&.map(&:to_i)&.join(', ')

    return 'TRUE' if country_ids_sql.blank?

    # This should be true for reported_by_party tab, false for the reported_by_partners
    reported_by_party = sanitise_boolean(@reported_by_party)

    <<-SQL.squish
      #{@reported_by}_id IN (#{country_ids_sql}) AND (
        (
          reported_by_exporter = #{!reported_by_party} AND importer_id IN (#{country_ids_sql})
        ) OR (
          reported_by_exporter = #{reported_by_party} AND exporter_id IN (#{country_ids_sql})
        )
      )
    SQL
  end

  def having_quantity_sql(field)
    "HAVING ROUND(SUM(#{db.quote_column_name field}::FLOAT)) > 0.49"
  end

  def limit
    pagination = @pagination.presence || { page: 1, per_page: @limit || 0 }
    per_page = pagination[:per_page]
    offset = (pagination[:page] - 1) * per_page

    per_page > 0 ? "LIMIT #{pagination[:per_page].to_i} OFFSET #{offset.to_i}" : ''
  end

  # Used in the base class to skip taxon_id equality check
  # as it will be managed by the child_taxa recursive query
  def skip_taxon_id?
    @opts['taxon_id'].present?
  end
end
