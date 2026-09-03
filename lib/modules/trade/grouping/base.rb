class Trade::Grouping::Base
  attr_reader :query, :grouping_attribute_names
  attr_reader :grouping_attribute_names

  # Not quite the same set as Rank.dict
  TAXONOMIC_LEVELS = [ 'kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'taxon' ].freeze
  TAXONOMIC_GROUPING = 'lib/data/group_conversions.csv'.freeze

  YEARS = (2012..(Date.today.year - 1)).to_a

  def initialize(opts = {})
    @opts = opts.clone

    # TODO: there's certainly a better way to do this
    # See https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/347
    raise ArgumentError, 'Bad reported_by' unless opts[:reported_by].blank? || %w[importer exporter].include?(opts[:reported_by])
    raise ArgumentError, 'Bad reported_by_party' unless opts[:reported_by_party].blank? || /\A\w+\z/.match?(opts[:reported_by_party])
    raise ArgumentError, 'Bad locale' unless I18n.available_locales.map(&:to_s).include?(@opts[:locale] ||= I18n.locale.to_s)
    raise ArgumentError, 'Bad taxonomic_level' unless opts[:taxonomic_level].blank? || TAXONOMIC_LEVELS.include?(opts[:taxonomic_level])
    raise ArgumentError, 'Bad group_name' unless opts[:group_name].blank? || /\A\w+\z/.match?(opts[:group_name])
    raise ArgumentError, 'Bad country_ids' unless opts[:country_ids].blank? || /\A[\d,]+\z/.match?(opts[:country_ids])
    raise ArgumentError, 'Bad origin_ids' unless opts[:origin_ids].blank? || /\A[\w,]+\z/.match?(opts[:origin_ids])
    raise ArgumentError, 'Bad taxon_id' unless opts[:taxon_id].blank? || /\A[\d,]+\z/.match?(opts[:taxon_id])
    raise ArgumentError, 'Bad time_range_end' unless opts[:time_range_end].blank? || /\A\d+\z/.match?(opts[:time_range_end])
    raise ArgumentError, 'Bad time_range_start' unless opts[:time_range_start].blank? || /\A\d+\z/.match?(opts[:time_range_start])
    raise ArgumentError, 'Bad unit_id' unless opts[:unit_id].blank? || /\A[\w,]+\z/.match?(opts[:unit_id])


    @grouping_attribute_names = self.class.build_grouping_attributes(
      @opts[:group_by], @opts[:locale]
    )

    @attributes = sanitise_params(@grouping_attribute_names)

    @locale = @opts[:locale]
    @condition = sanitised_condition_sql
    @limit = sanitise_limit(opts[:limit])
    @pagination = sanitise_pagination(opts)
    @query = group_query
  end

  def run
    db.execute(@query)
  end

  def shipments
    sql = <<-SQL.squish
      SELECT *
      FROM #{shipments_table}
    SQL

    db.execute(sql)
  end

  def json_by_attribute(data, opts = {})
    raise NoMethodError
  end

  def read_taxonomy_conversion
    conversion = {}
    taxonomy = CSV.read(TAXONOMIC_GROUPING, headers: true)
    taxonomy.each do |csv|
      conversion[csv['group']] ||= []
      data = {
        taxon_name: csv['taxon_name'],
        rank: csv['taxonomic_level']
      }
      conversion[csv['group']] << data
    end
    conversion
  end

  delegate :sanitise_integer_array, to: :class

  def self.sanitise_integer_array(original, param_name_for_error)
    if original.is_a? Array
      original
    else
      original&.to_s&.split(',') || []
    end.compact.map(&:squish).map do |item|
      if /\A[-+]?\d+\z/.match item
        item.to_i
      elsif param_name_for_error
        raise(
          ArgumentError, "Not an integer in #{param_name_for_error}"
        )
      else
        nil
      end
    end.compact
  end

protected

  def shipments_table
    raise NoMethodError
  end

  ##
  # This defines which columns are selected and returned
  def attributes
    raise NoMethodError
  end

  ##
  # This defines which attributes can be used for filtering, and how the
  # parameters map to columns and SQL WHERE conditions.
  #
  # {
  #   [attribute_name]: {
  #     column_name: # the column in the view to reference
  #     operator: :gteq # the Arel operator method to use, e.g. :gteq for time_range_start.
  #     type: :integer # or :text
  #     null_values = [ 'unreported', 'direct', 'items' ]
  #     default: 0 # optional default value
  #   }
  # }
  # ```
  def filterable_attributes
    raise NoMethodError
  end

  ##
  # A hash whose keys are parameter names and whose values are the default
  # values that are supplied if the parameters are not supplied.
  #
  # ```
  # {
  #   time_range_start: 2020
  # }
  # ```
  def default_filtering_attributes
    filterable_attributes.select do |key, value|
      value.has_key? :default
    end.transform_values do |value|
      value[:default]
    end
  end

  def grouping_attributes_by_group
    self.class.build_grouping_attributes_by_group(@locale)
  end

  def self.build_grouping_attributes_by_group(locale_param)
    raise NoMethodError
  end

  def self.build_grouping_attributes(group_by_param, locale_param)
    return [] if group_by_param.blank?

    built_grouping_attributes_by_group =
      build_grouping_attributes_by_group(locale_param)

    Array.wrap(group_by_param).compact.map do |group_by_attr|
      built_grouping_attributes_by_group[group_by_attr.to_sym]
    end.flatten.compact.uniq
  end

  def group_query
    columns = sanitised_columns_sql @attributes

    <<-SQL.squish
      SELECT #{columns}, COUNT(*) AS cnt
      FROM #{shipments_table}
      WHERE #{@condition}
      GROUP BY #{columns}
      ORDER BY cnt DESC
      #{limit}
    SQL
  end

  def limit
    @limit ? "LIMIT #{@limit}" : ''
  end
private

  def sanitise_group(group)
    return nil unless group

    attributes[group.to_sym]
  end

  def sanitise_params(params_attributes)
    return [] if params_attributes.blank?

    Array.wrap(params_attributes.presence || []).compact.uniq.map do |p|
      attributes[p.to_sym]
    end.compact
  end

  def sanitise_limit(limit)
    limit.is_a?(Integer) ? limit : nil
  end

  def sanitise_pagination(opts)
    page, per_page = [ opts[:page].to_i, opts[:per_page].to_i ]
    return {} unless page > 0 || per_page > 0

    {
      page: page,
      per_page: per_page
    }
  end

  ##
  # Given a list of column names, return an SQL string with a unique list of
  # quoted column names. If this list is empty, `attributes` is used instead.
  def sanitised_columns_sql(attribute_names)
    column_names = attribute_names&.compact&.uniq&.presence || attributes.values

    column_names.map do |column_name|
      db.quote_column_name column_name
    end.join(', ')
  end

  def sanitised_condition_sql
    condition_attributes =
      @opts.select do |k, v|
        filterable_attributes.has_key?(k.to_sym) && v.present?
      end.to_h

    # Get default attributes if missing from params
    if @opts[:with_defaults]
      condition_attributes.reverse_merge!(default_filtering_attributes)
    end

    return 'TRUE' if condition_attributes.blank?

    condition_attributes.map do |key, value|
      filterable_attribute = filterable_attributes[key.to_sym]

      next unless filterable_attribute && filterable_attribute[:column_name]

      # taxon_id equality check can be skipped as this is also managed through the recursive child_taxa query
      # in TradeVis
      next if filterable_attribute[:column_name] == 'taxon_id' && skip_taxon_id?

      attribute_filter_sql(filterable_attribute, value)
    end.compact.reduce(&:and).presence&.to_sql || 'TRUE'
  end

  def skip_taxon_id?
    raise NoMethodError
  end

  # TODO This is shared between the ComplianceTool and TradePlus,
  # so make sure the other tool won't break after making changes for one of them,
  # or override this function in each related module.
  def attribute_filter_sql(filterable_attribute, value)
    column_name = filterable_attribute[:column_name]
    null_values = filterable_attribute[:null_values]&.map(&:downcase) || []

    arel_table = Arel::Table.new(shipments_table.to_sym)
    arel_attribute = arel_table[column_name.to_sym]

    left_hand_side =
      if filterable_attribute[:transform] == :downcase
        Arel::Nodes::NamedFunction.new('LOWER', [ arel_attribute ])
      else
        arel_attribute
      end

    # Here on out we are constructing the return value for attribute_filter_sql
    if value&.to_s&.squish&.downcase == 'null'
      # column_name IS NULL
      arel_attribute.eq(nil)
    elsif filterable_attribute[:multiple]
      # column_name IN (...values)
      operator_symbol = filterable_attribute[:operator] || :in
      should_find_null = false
      values = value.split(',').map(&:squish)

      if filterable_attribute[:transform] == :downcase
        values = values.map(&:downcase)
      end

      values.delete_if do |v|
        should_find_null = true if null_values.include? v&.downcase
      end if null_values.present?

      if filterable_attribute[:type] == :integer
        values = sanitise_integer_array(values, column_name)
      end

      if values.present? && should_find_null
        # column_name IN (1, 2) OR column_name IS NULL
        left_hand_side.send(operator_symbol, values).or(
          arel_attribute.eq(nil)
        )
      elsif values.present?
        # column_name IN (1, 2)
        left_hand_side.send(operator_symbol, values)
      elsif should_find_null
        arel_attribute.eq(nil)
      else
        # Only an explicit NULL is treated as a IS NULL condition
        nil
      end
    elsif value.nil?
      # Only an explicit NULL is treated as a IS NULL condition
      nil
    else
      # column_name = 'value'
      arel_attribute.send(filterable_attribute[:operator] || :eq, value)
    end
  end

  def db
    ApplicationRecord.connection
  end
end
