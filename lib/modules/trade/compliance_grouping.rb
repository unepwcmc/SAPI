class Trade::ComplianceGrouping
  attr_reader :query

  # Allowed attributes
  ATTRIBUTES = {
    id: 'id',
    year: 'year',
    importer: 'importer',
    exporter: 'exporter',
    term: 'term',
    unit: 'unit',
    purpose: 'purpose',
    source: 'source',
    taxon: 'taxon',
    genus: 'genus',
    family: 'family',
    class: 'class'
  }

  # Example usage
  # Group by year considering compliance types:
  # Trade::ComplianceGrouping.new('year', {all: false})
  # Group by importer across all shipments and limit result to 5 records
  # Trade::ComplianceGrouping.new('importer', {all: true, limit: 5})
  def initialize(group, opts={})
    @group = sanitise_group(group)
    @attributes = sanitise_params(opts[:attributes])
    @limit = sanitise_limit(opts[:limit])
    @all = opts[:all]
    @query = "#{non_compliant_shipments}#{group_query}"
  end

  private

  def group_query
    # If @all is true it means we are considering all shipment at once,
    # without taking care of their compliance type.
    # If @all is false instead, we are also grouping by compliance type
    # and considering shipments separately.
    compliance_type = @all ? nil : 'compliance_type'
    columns = [@group, @attributes, compliance_type].flatten.compact.uniq.join(',')
    <<-SQL
      SELECT #{columns}, cnt, 100.0*cnt/(SUM(cnt) OVER ()) AS percent
      FROM (
        SELECT #{columns}, COUNT(*) AS cnt
        FROM non_compliant_shipments
        GROUP BY #{columns}
      ) counts
      ORDER BY percent DESC
      #{limit}
    SQL
  end

  def non_compliant_shipments
    # For the reason stated above, if @all is true we need just UNION,
    # otherwise, in order to consider the shipments separately by compliance type,
    # we need UNION ALL, which allows duplicated shipments.
    <<-SQL
      WITH non_compliant_shipments AS (
        (
          SELECT #{ATTRIBUTES.values.join(',')}, 'appendixI' AS compliance_type
          FROM trade_shipments_appendix_i_mview
        )
        #{@all ? 'UNION' : 'UNION ALL'}
        (
          SELECT #{ATTRIBUTES.values.join(',')}, 'quotas' AS compliance_type
          FROM trade_shipments_mandatory_quotas_mview
        )
        #{@all ? 'UNION' : 'UNION ALL'}
        (
          SELECT #{ATTRIBUTES.values.join(',')}, 'suspension' AS compliance_type
          FROM trade_shipments_cites_suspensions_mview
        )
      )
    SQL
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
end
