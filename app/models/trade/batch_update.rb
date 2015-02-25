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
    return 0 unless update_params.keys.size > 0
    disconnected_permits_ids = @shipments.map do |s|
      s.permits_ids
    end.flatten.uniq
    affected_shipments = nil
    Trade::Shipment.transaction do
      affected_shipments = @shipments.count
      @shipments.update_all(update_params)
      DownloadsCache.clear_shipments
    end
    PermitCleanupWorker.perform_async(disconnected_permits_ids)
    affected_shipments
  end

end
