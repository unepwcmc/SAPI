class Api::V1::ShipmentsController < ApplicationController
  respond_to :json

  before_filter :authenticate

  def index
    @search = Trade::Filter.new(search_params)
    render :json => @search.results,
      :each_serializer => Trade::ShipmentFromViewSerializer,
      :meta => metadata_for_search(@search)
  end

  private

  def search_params
    params.permit(:compliance_type)
  end

  def authenticate
    token = request.headers['X-Authentication-Token']
    unless token == Rails.application.secrets["compliance_tool_token"]
      head status: :unauthorized
      return false
    end
  end


end
