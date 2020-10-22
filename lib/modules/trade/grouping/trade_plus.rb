class Trade::Grouping::TradePlus

  def initialize(attributes, opts={})
    super(attributes, opts)
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

  def shipments_table
    'trade_plus_shipments_view'
  end

  def attributes
    #TODO
  end
end
