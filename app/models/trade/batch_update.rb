class Trade::BatchUpdate

  def initialize(search_params)
    search = Trade::Filter.new(search_params)
    @shipments = Trade::Shipment.joins(
      <<-SQL
      JOIN (
        #{search.query.to_sql}
      ) q
      ON q.id = trade_shipments.id
      SQL
    )
  end

  def execute(update_params)
    @shipments.update_all(update_params)
    DownloadsCache.clear_shipments
  end

end
