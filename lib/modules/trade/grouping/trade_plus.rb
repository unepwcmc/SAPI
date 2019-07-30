class Trade::Grouping::TradePlus

  def initialize(group, opts={})
    super(group, opts)
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

  private

  def shipments_table
    'trade_plus_shipments_view'
  end

  def attributes
    #TODO
  end
end
