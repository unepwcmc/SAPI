class Trade::Grouping::Base
  attr_reader :query

  TAXONOMIC_GROUPING = 'lib/data/group_conversions.csv'.freeze

  YEARS = (2012..Date.today.year - 1).to_a

  # Example usage
  # Group by year considering compliance types:
  # Trade::Grouping::Compliance.new(['year, 'issue_type']})
  # Group by importer and limit result to 5 records
  # Trade::Grouping::Compliance.new('importer', {limit: 5})
  def initialize(attributes, opts={})
    @attributes = sanitise_params(attributes)
    @opts = opts.clone
    @condition = sanitise_condition
    @limit = sanitise_limit(opts[:limit])
    @query = group_query
  end

  def run
    db.execute(@query)
  end

  def shipments
    sql = <<-SQL
      SELECT *
      FROM #{shipments_table}
    SQL
    db.execute(sql)
  end

  def json_by_attribute(data, opts={})
    raise NotImplementedError
  end

  protected

  def shipments_table
    raise NotImplementedError
  end

  def attributes
    raise NotImplementedError
  end

  def self.filtering_attributes
    raise NotImplementedError
  end

  def self.default_filtering_attributes
    raise NotImplementedError
  end

  def self.grouping_attributes
    raise NotImplementedError
  end

  def self.get_grouping_attributes(group)
    Array.new(grouping_attributes[group.to_sym])
  end

  def group_query
    columns = @attributes.compact.uniq.join(',')
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

  def read_taxonomy_conversion
    conversion = {}
    taxonomy = CSV.read(TAXONOMIC_GROUPING, {headers: true})
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

  def limit
    @limit ? "LIMIT #{@limit}" : ''
  end

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

  def sanitise_condition
    filtering_attributes = self.class.filtering_attributes
    condition_attributes = @opts.keep_if do |k, v|
      filtering_attributes.key?(k.to_sym) && v.present?
    end
    # Get default attributes if missing from params
    if @opts[:with_defaults]
      condition_attributes.reverse_merge!(self.class.default_filtering_attributes)
    end

    return 'TRUE' if condition_attributes.blank?

    condition_attributes.map do |key, value|
      val = get_condition_value(key.to_sym, value)
      "#{filtering_attributes[key.to_sym]} #{val}"
    end.join(' AND ')
  end

  def get_condition_value(key, value)
    # It's not a number (positive number to be precise
    if !/\A\d+\z/.match(value)
      value = value.split(',').map { |v| "'#{v}'" }.join(',')
      return "IN (#{value})"
    end

    return "IS NULL" if value == 'NULL'

    operator = case key
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
    ActiveRecord::Base.connection
  end

end
