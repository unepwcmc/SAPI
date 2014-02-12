class Api::V1::StatsController < ApplicationController

  def index
    iso_code = params['iso_code']
    kingdom = params['kingdom']
    trade_limit = params['limit']
    geo_entity = GeoEntity.where(:iso_code2 => iso_code).first
    stats = DashboardStats.new(iso_code, kingdom, trade_limit)
    render :json => stats, :serializer => TaxonConceptStatsSerializer
  end

end