class Api::V1::DashboardStatsController < ApplicationController

  def index
    stats = DashboardStats.new(params['iso_code'], params['kingdom'], params['trade_limit'])
    render :json => stats, :serializer => DashboardStatsSerializer
  end

end