class Api::V1::DashboardStatsController < ApplicationController

  def index
    iso_code = params['iso_code'].upcase
    geo_entity = GeoEntity.where(:iso_code2 => iso_code).first
    if geo_entity
      stats = DashboardStats.new(geo_entity, params['kingdom'], params['trade_limit'])
      render :json => stats, :serializer => DashboardStatsSerializer
    else
      render :json => { "error" => "#{iso_code} is not a valid iso2 code!" },
             :status => :unprocessable_entity
    end
  end

end