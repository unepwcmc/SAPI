class Trade::ComplianceGrouping
  attr_reader :query

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
    unit: 'unit',
    purpose: 'purpose',
    source: 'source',
    taxon: 'taxon',
    genus: 'genus',
    family: 'family',
    class: 'class',
    issue_type: 'issue_type'
  }

  COUNTRIES = 183.freeze

  # Example usage
  # Group by year considering compliance types:
  # Trade::ComplianceGrouping.new('year', {attributes: ['issue_type']})
  # Group by importer and limit result to 5 records
  # Trade::ComplianceGrouping.new('importer', {limit: 5})
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

  def json_by_year(data, opts={})
    return data unless data.first["year"]

    # Custom group_by
    years = data.map { |d| d["year"] }.uniq
    json = []
    years.map do |year|
      partials = data.select { |d| d["year"] == year }
      values = partials.map do |partial|
        hash = {}
        opts.each { |key, value| hash.merge!({"#{key}": partial[value]}) }
        hash.merge({
          value: partial['cnt'],
          percent: partial['percent']
        })
      end
      json << ({ "#{year}": values })
    end
    json
  end

  def countries_reported_range(year)
    years = [year - 1, year, year + 1]
    hash = {}
    years.map do |y|
      data = countries_reported(y)
      hash[year] ||= []
      hash[year] << data
    end
    hash
  end

  private

  def group_query
    columns = [@group, @attributes].flatten.compact.uniq.join(',')
    <<-SQL
      #{non_compliant_shipments}
      SELECT #{columns}, COUNT(*) AS cnt, 100.0*COUNT(*)/(SUM(COUNT(*)) OVER (PARTITION BY year)) AS percent
      FROM non_compliant_shipments
      WHERE #{@condition}
      GROUP BY #{columns}
      ORDER BY percent DESC
      #{limit}
    SQL
  end

  def non_compliant_shipments
    # We need UNION ALL, which allows duplicated shipments.
    <<-SQL
      WITH non_compliant_shipments AS (
        (
          SELECT #{ATTRIBUTES.values.join(',')}
          FROM trade_shipments_appendix_i_mview
        )
        UNION ALL
        (
          SELECT #{ATTRIBUTES.values.join(',')}
          FROM trade_shipments_mandatory_quotas_mview
        )
        UNION ALL
        (
          SELECT #{ATTRIBUTES.values.join(',')}
          FROM trade_shipments_cites_suspensions_mview
        )
      )
    SQL
  end

  def countries_reported(year)
    sql = <<-SQL
      #{non_compliant_shipments}
      SELECT COUNT(*) AS cnt
      FROM(
        (
          SELECT DISTINCT importer AS country, importer_iso AS iso
          FROM non_compliant_shipments
          WHERE year = #{year}
        )
        UNION
        (
          SELECT DISTINCT exporter AS country, exporter_iso AS iso
          FROM non_compliant_shipments
          WHERE year = #{year}
        )
      ) AS countries
    SQL
    countries_reported = db.execute(sql).first['cnt'].to_i

    sql = <<-SQL
      #{non_compliant_shipments}
      SELECT COUNT(*) AS cnt
      FROM non_compliant_shipments
      WHERE year = #{year}
    SQL
    issues_reported = db.execute(sql).first['cnt'].to_i

    {
      year: year,
      issuesReported: issues_reported,
      countriesReported: countries_reported,
      countriesYetToReport: COUNTRIES-countries_reported
    }
  end

  def limit
    @limit ? "LIMIT #{@limit}" : ''
  end

  def sanitise_group(group)
    ATTRIBUTES[group.to_sym]
  end

  def sanitise_params(params)
    return nil if params.blank?
    params.map { |p| ATTRIBUTES[p.to_sym] }
  end

  def sanitise_limit(limit)
    limit.is_a?(Integer) ? limit : nil
  end

  def sanitise_condition(condition)
    # TODO
    return nil if condition.blank?
    condition.map do |key, value|
      if value.is_a?(Array)
        "#{ATTRIBUTES[key]} IN (#{value.join(',')})"
      else
        "#{ATTRIBUTES[key]} = #{value}"
      end
    end.join(' AND ')
  end

  def db
    ActiveRecord::Base.connection
  end
end
