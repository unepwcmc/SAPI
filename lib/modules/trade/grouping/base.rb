class Trade::Grouping::Base
  attr_reader :query

  TAXONOMIC_GROUPING = 'lib/data/group_conversions.csv'.freeze

  YEARS = (2012..Date.today.year - 1).to_a

  # Example usage
  # Group by year considering compliance types:
  # Trade::Grouping::Compliance.new('year', {attributes: ['issue_type']})
  # Group by importer and limit result to 5 records
  # Trade::Grouping::Compliance.new('importer', {limit: 5})
  def initialize(opts={})
    @attributes = sanitise_params(opts[:attributes])
    @condition = opts[:condition] || 'TRUE'
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
    attribute = sanitise_group(opts[:attribute])

    begin
      raise NoGroupingAttributeError unless attribute
    rescue => e
      attribute = 'year'
      Rails.logger.info(e)
    end

    grouped_data = data.group_by { |d| d[attribute] }
    grouped_data.each do |key, values|
      # Fetch top 5 and rename 'cnt' to 'value'
      grouped_data[key] = values[0..4].each { |v| v['value'] = v.delete('cnt') }
    end
  end

  protected

  def shipments_table
    raise NotImplementedError
  end

  def attributes
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
    params.map { |p| attributes[p.to_sym] }
  end

  def sanitise_limit(limit)
    limit.is_a?(Integer) ? limit : nil
  end

  def db
    ActiveRecord::Base.connection
  end

end
