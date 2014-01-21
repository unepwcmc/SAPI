class Trade::SandboxShipmentsController < ApplicationController
  respond_to :json

  def index
    @search = Trade::SandboxFilter.new(params)
    render :json => @search.results,
      :each_serializer => Trade::SandboxShipmentSerializer,
      :meta => {
      :total => @search.total_cnt,
      :page => @search.page,
      :per_page => @search.per_page
    }
  end
end
