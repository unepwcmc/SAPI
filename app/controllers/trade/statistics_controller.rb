class Trade::StatisticsController < ApplicationController
  layout 'admin'

  def index
    @years = (1975..Date.today.year).to_a.reverse
    @total_shipments = Trade::Shipment.count
    @last_updated = Trade::Shipment.maximum(:updated_at).year
    @shipments_uploaded_2013 = Trade::Shipment.where(:created_at => '2013-01-01 00:00:00'..'2013-12-31 23:59:59').count
    @shipments_amended_2013 = Trade::Shipment.where(:updated_at => '2013-01-01 00:00:00'..'2013-12-31 23:59:59').count
    @taxon_concepts_in_trade = Trade::Shipment.count(:taxon_concept_id, :distinct => true)
  end

end
