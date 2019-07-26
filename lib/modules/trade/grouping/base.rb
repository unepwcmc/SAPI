class Trade::Grouping::Base
  attr_reader :query

  # Allowed attributes
  ATTRIBUTES = {
    id: 'id',
    year: 'year',
    appendix: 'appendix',
    importer: 'importer',
    importer_iso: 'importer_iso',
    importer_id: 'importer_id',
    exporter: 'exporter',
    exporter_iso: 'exporter_iso',
    exporter_id: 'exporter_id',
    term: 'term',
    term_id: 'term_id',
    unit: 'unit',
    purpose: 'purpose',
    source: 'source',
    taxon_name: 'taxon_name',
    genus_name: 'genus_name',
    family_name: 'family_name',
    class_name: 'class_name',
    issue_type: 'issue_type',
    taxon_concept_id: 'taxon_concept_id'
  }

  COUNTRIES = {
    2018 => 182,
    2017 => 182,
    2016 => 182,
    2015 => 180,
    2014 => 180,
    2013 => 179,
    2012 => 176,
    2011 => 175
  }

  TAXONOMIC_GROUPING = 'lib/data/group_conversions.csv'.freeze

  YEARS = (2012..Date.today.year - 1).to_a

  # Example usage
  # Group by year considering compliance types:
  # Trade::Grouping::Compliance.new('year', {attributes: ['issue_type']})
  # Group by importer and limit result to 5 records
  # Trade::Grouping::Compliance.new('importer', {limit: 5})
  def initialize(group, opts={})
    @group = sanitise_group(group)
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

  def group_query
    columns = [@group, @attributes].flatten.compact.uniq.join(',')
    <<-SQL
      SELECT #{columns}, COUNT(*) AS cnt
      FROM #{shipments_table}
      WHERE #{@condition}
      GROUP BY #{columns}
      ORDER BY cnt DESC
      #{limit}
    SQL
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

  private

  def limit
    @limit ? "LIMIT #{@limit}" : ''
  end

  def sanitise_group(group)
    return nil unless group
    ATTRIBUTES[group.to_sym]
  end

  def sanitise_params(params)
    return nil if params.blank?
    params.map { |p| ATTRIBUTES[p.to_sym] }
  end

  def sanitise_limit(limit)
    limit.is_a?(Integer) ? limit : nil
  end

  def db
    ActiveRecord::Base.connection
  end

end
