class Api::V1::ShipmentsController < ApplicationController
  respond_to :json

  before_filter :authenticate

  def index
    @search = Trade::Filter.new(search_params)
    render :json => @search.results,
      :each_serializer => Trade::ShipmentApiFromViewSerializer,
      :meta => metadata_for_search(@search)
  end

  def grouped_query
    query = Trade::ComplianceGrouping.new('year', {attributes: params[:group_by], condition: 'year >= 2012 AND year <= 2016', limit: params[:limit].present? ? params[:limit].to_i : '' })
    data = query.run
    params_hash = {}
    params[:group_by].map { |p| params_hash[p] = p }
    @grouped_data = params[:group_by].first.empty? ? query.taxonomic_grouping :
                                                     query.json_by_year(data, params_hash)
    render :json => @grouped_data
  end

  private

  def search_params
    params.permit(:compliance_type, :time_range_start, :time_range_end, :page, :per_page)
  end

  def authenticate
    token = request.headers['X-Authentication-Token']
    unless token == Rails.application.secrets["compliance_tool_token"]
      head status: :unauthorized
      return false
    end
  end


end
