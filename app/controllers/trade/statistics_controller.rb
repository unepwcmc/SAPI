class Trade::StatisticsController < ApplicationController
  layout 'admin'
  require Statistics

  def index
  	@start_date = params[:stats_start_date] || Date.today.strftime("01/01/%Y")
  	@end_date = params[:stats_end_date] || Date.today.strftime("%d/%m/%Y")
    @years = (1975..Date.today.year).to_a.reverse
    @total_shipments = Trade::Shipment.count
    @last_updated = Trade::Shipment.maximum(:updated_at).strftime("%d/%m/%Y %H:%M")
    @shipments_uploaded = Trade::Shipment.where(:created_at => params[:stats_start_date]..params[:stats_end_date]).count
    @shipments_amended = Trade::Shipment.where(:updated_at => params[:stats_start_date]..params[:stats_end_date]).count
    @taxon_concepts_in_trade = Trade::Shipment.count(:taxon_concept_id, :distinct => true)
    @statistics_table = Statistics.get_total_transactions_per_year
  end



end
