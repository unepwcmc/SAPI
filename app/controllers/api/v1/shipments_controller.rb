class Api::V1::ShipmentsController < ApplicationController
  respond_to :json

  before_filter :authenticate

  GROUPING_ATTRIBUTES = {
    category: ['issue_type'],
    commodity: ['term', 'term_id'],
    exporting: ['exporter', 'exporter_iso', 'exporter_id'],
    importing: ['importer', 'importer_iso', 'importer_id'],
    species: ['taxon_name', 'appendix', 'taxon_concept_id'],
    taxonomy: [''],
  }

  def index
    @search = Trade::Filter.new(search_params)
    render :json => @search.results,
      :each_serializer => Trade::ShipmentApiFromViewSerializer,
      :meta => metadata_for_search(@search)
  end

  def grouped_query
    limit = params[:limit].present? ? params[:limit].to_i : ''
    query = Trade::ComplianceGrouping.new('year', {attributes: sanitized_attributes, condition: 'year >= 2012 AND year <= 2016', limit: limit })
    data = query.run
    params_hash = {}
    sanitized_attributes.map { |p| params_hash[p] = p }
    @grouped_data = sanitized_attributes.first.empty? ? query.taxonomic_grouping :
                                                        query.json_by_year(data, params, params_hash)
    render :json =>  @grouped_data
  end

  def search_query
    query = Trade::ComplianceGrouping.new('year', {attributes: sanitized_attributes, condition: "year = #{params[:year]}"})
    data = query.run
    @search_data = query.build_hash(data, params)
    render :json => Kaminari.paginate_array(query.filter(@search_data, params)).page(params[:page]).per(8)
  end

  private

  def search_params
    params.permit(:compliance_type, :time_range_start, :time_range_end, :page, :per_page)
  end

  def sanitized_attributes
    GROUPING_ATTRIBUTES[params[:group_by].to_sym]
  end

  def authenticate
    token = request.headers['X-Authentication-Token']
    unless token == Rails.application.secrets["compliance_tool_token"]
      head status: :unauthorized
      return false
    end
  end
end
