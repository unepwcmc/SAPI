class Trade::StatisticsController < ApplicationController
  layout 'admin'

  def index
  	@start_date = params[:stats_start_date] ? Date.parse(params[:stats_start_date]) : Date.today.beginning_of_year
  	@end_date = params[:stats_end_date] ? Date.parse(params[:stats_end_date]) : Date.today
    @years = (1975..Date.today.year).to_a.reverse
    @total_shipments = Trade::Shipment.count
    @last_updated = Trade::Shipment.maximum(:updated_at).strftime("%d/%m/%Y %H:%M")
    @shipments_uploaded = Trade::Shipment.
      where("created_at::DATE BETWEEN ? AND ?", @start_date, @end_date).
      count
    @shipments_amended = Trade::Shipment.
      where("created_at::DATE BETWEEN ? AND ?", @start_date, @end_date).
      where('created_at != updated_at').
      count
    @taxon_concepts_in_trade = Trade::Shipment.count(:taxon_concept_id, :distinct => true)
    @transactions = Statistics.get_total_transactions_per_year
  end

  def summary_creation
    @created_date_selected = params[:date] ? params[:date]['createdDateSelected'] : Date.today.year
    @countries_reported_by_date_created = YearAnnualReportsByCountry.where(
      :year_created => @created_date_selected)
  end

  def summary_year
    @date_selected = params[:date] ? Date.parse("01/01/#{params[:date]['yearSelected']}") : Date.today
    @countries_reported_by_year = YearAnnualReportsByCountry.where(:year => @date_selected.year)
  end
end
