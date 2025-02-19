class Trade::Grouping::Base
  attr_reader :query

  TAXONOMIC_GROUPING = 'lib/data/group_conversions.csv'.freeze

  YEARS = (2012..Date.today.year - 1).to_a

  # Example usage
  # Group by year considering compliance types:
  # Trade::Grouping::Compliance.new(['year, 'issue_type']})
  # Group by importer and limit result to 5 records
  # Trade::Grouping::Compliance.new('importer', {limit: 5})
  def initialize(attributes, opts = {})
    # TODO: there's certainly a better way to do this
    # See https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/347
    raise ArgumentError, 'Bad reported_by' unless opts[:reported_by].blank? || /\A\w+\z/.match?(opts[:reported_by])
    raise ArgumentError, 'Bad reported_by_party' unless opts[:reported_by_party].blank? || /\A\w+\z/.match?(opts[:reported_by_party])
    raise ArgumentError, 'Bad locale' unless opts[:locale].blank? || /\A\w+\z/.match?(opts[:locale])
    raise ArgumentError, 'Bad taxonomic_level' unless opts[:taxonomic_level].blank? || /\A\w+\z/.match?(opts[:taxonomic_level])
    raise ArgumentError, 'Bad group_name' unless opts[:group_name].blank? || /\A\w+\z/.match?(opts[:group_name])
    raise ArgumentError, 'Bad country_ids' unless opts[:country_ids].blank? || /\A[\d,]+\z/.match?(opts[:country_ids])
    raise ArgumentError, 'Bad origin_ids' unless opts[:origin_ids].blank? || /\A[\w,]+\z/.match?(opts[:origin_ids])
    raise ArgumentError, 'Bad taxon_id' unless opts[:taxon_id].blank? || /\A[\d,]+\z/.match?(opts[:taxon_id])
    raise ArgumentError, 'Bad time_range_end' unless opts[:time_range_end].blank? || /\A\d+\z/.match?(opts[:time_range_end])
    raise ArgumentError, 'Bad time_range_start' unless opts[:time_range_start].blank? || /\A\d+\z/.match?(opts[:time_range_start])
    raise ArgumentError, 'Bad unit_id' unless opts[:unit_id].blank? || /\A[\w,]+\z/.match?(opts[:unit_id])

    @attributes = sanitise_params(attributes)
    @opts = opts.clone
    @condition = sanitise_condition
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

protected

  def shipments_table
    raise NoMethodError
  end

  def attributes
    raise NoMethodError
  end

  def self.filtering_attributes
    raise NoMethodError
  end

  def self.default_filtering_attributes
    raise NoMethodError
  end

  def self.grouping_attributes
    raise NoMethodError
  end

  def self.get_grouping_attributes(group, locale = nil)
    @locale = locale
    Array.new(grouping_attributes[group.to_sym])
  end

  def group_query
    columns = @attributes.compact.uniq.join(',')
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

  def sanitise_params(params)
    return nil if params.blank?

    Array.wrap(params).map { |p| attributes[p.to_sym] }
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

  def sanitise_condition
    filtering_attributes = self.class.filtering_attributes
    condition_attributes =
      @opts.keep_if do |k, v|
        filtering_attributes.key?(k.to_sym) && v.present?
      end
    unless condition_attributes.is_a?(Hash)
      condition_attributes.permit!
      condition_attributes = condition_attributes.to_h
    end
    # Get default attributes if missing from params
    if @opts[:with_defaults]
      condition_attributes.reverse_merge!(self.class.default_filtering_attributes)
    end

    return 'TRUE' if condition_attributes.blank?

    condition_attributes.map do |key, value|
      val = get_condition_value(key.to_sym, value)
      column = filtering_attributes[key.to_sym]
      # taxon_id equality check can be skipped as this is also managed through the recursive child_taxa query
      # in TradeVis
      next if column == 'taxon_id' && skip_taxon_id?

      column = "LOWER(#{column})" unless [ 'year', 'appendix' ].include?(column) || is_id_column?(column)

      "(#{column} #{val})"
    end.compact.join(' AND ')
  end

  def skip_taxon_id?
    raise NoMethodError
  end

  def is_id_column?(column)
    column.match(/_id(s)?/).present?
  end

  # TODO This is shared between the ComplianceTool and TradePlus,
  # so make sure the other tool won't break after making changes for one of them,
  # or override this function in each related module.
  def get_condition_value(key, value)
    column_name = self.class.filtering_attributes[key.to_sym]

    # It's not a number (positive number to be precise)
    if !/\A\d+\z/.match(value)
      case key
      when :appendices
        value = value.split(',').map { |v| "'#{v}'" }.join(',')
        return "IN (#{value})"
      when /_id(s)?/
        null = []
        values = value.split(',')
        values.delete_if { |v| null << v if [ 'unreported', 'direct', 'items' ].include? v.downcase }
        value = values.join(',')
        if value.present? && null.present?
          return "IN (#{value}) OR #{column_name} IS NULL"
        elsif value.present?
          return "IN (#{value})"
        elsif null.present?
          return 'IS NULL'
        else
          return ''
        end
      else
        value = value.split(',').map { |v| "'#{v.downcase}'" }.join(',')
        return "IN (#{value})"
      end

    end

    return 'IS NULL' if value == 'NULL'

    operator =
      case key
      when :time_range_start
        '>='
      when :time_range_end
        '<='
      else
        '='
      end
    "#{operator} #{value.to_i}"
  end

  def db
    ApplicationRecord.connection
  end
end
