class Api::V1::TradePlusFiltersController < ApplicationController
  respond_to :json

  def index
    TradePlusFiltersWorker.perform_async

    #TODO 
    render json: { status: 'started' }
  end

  def show
    data = Rails.cache.fetch('trade_plus_filters')
    json = data.presence || { status: 'pending' }

    render json: json
  end
end
