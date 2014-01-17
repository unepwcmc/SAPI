class Trade::SandboxShipmentsController < ApplicationController
  respond_to :json

  def index
    debugger
    @search = Trade::Filter.new(params)
    render :json => @search.results,
      :each_serializer => Trade::ShipmentSerializer,
      :meta => {
        :total => @search.total_cnt,
        :page => @search.page,
        :per_page => @search.per_page
      }
  end