class Trade::StatisticsController < ApplicationController
  layout 'admin'

  def index
    @years = (1975..Date.today.year).to_a.reverse
    @total_shipments = Trade::Shipment.count
  end

end
