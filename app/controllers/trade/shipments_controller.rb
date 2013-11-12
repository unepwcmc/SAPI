class Trade::ShipmentsController < ApplicationController
  respond_to :json

  def index
    @search = Trade::Filter.new(params)
    render :json => @search.results,
      :each_serializer => Trade::ShipmentSerializer,
      :meta => {
        :total => @search.total_cnt,
        :page => params[:page] || 1,
        :per_page => 25
      }
  end
end

