class Trade::ComplianceGrouping
  attr_reader :query

  ATTRIBUTES = {
    id: 'id',
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

  # Example usage: Trade::ComplianceGrouping.new('importer')
  def initialize(type, attributes=nil, limit=nil)
    @type = sanitise_type(type)
    @attributes = sanitise_params(attributes)
    @limit = sanitise_limit(limit)
    @query = "#{non_compliant_shipments}#{group}"
  end

  private

  def group
    columns = [@type, @attributes].flatten.compact.uniq.join(',')
    <<-SQL
      SELECT #{columns}, cnt, 100.0*cnt/(SUM(cnt) OVER ()) AS percent
      FROM (
        SELECT #{columns}, COUNT(*) AS cnt
        FROM non_compliant_shipments
        GROUP BY #{columns}
      ) counts
      ORDER BY percent DESC
    SQL
  end

  def non_compliant_shipments
    <<-SQL
      WITH non_compliant_shipments AS (
        (
          SELECT #{ATTRIBUTES.values.join(',')}
          FROM trade_shipments_appendix_i_mview
        )
        UNION
        (
          SELECT #{ATTRIBUTES.values.join(',')}
          FROM trade_shipments_mandatory_quotas_mview
        )
        UNION
        (
          SELECT #{ATTRIBUTES.values.join(',')}
          FROM trade_shipments_cites_suspensions_mview
        )
      )
    SQL
  end

  def sanitise_type(type)
    ATTRIBUTES[type.to_sym]
  end

  def sanitise_params(params)
    return nil if params.blank?
    params.map { |p| ATTRIBUTES[p.to_sym] }
  end

  def sanitise_limit(limit)
    limit.is_a?(Integer) ? limit : nil
  end
end
