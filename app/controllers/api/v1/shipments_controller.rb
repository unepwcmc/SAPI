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
    @filtered_data = query.filter(@search_data, params)
    render :json => Kaminari.paginate_array(@filtered_data).page(params[:page]).per(params[:per_page]),
           :meta => metadata(@filtered_data, params)
  end

  def download_data
    @download_data = Trade::DownloadDataRetriever.dashboard_download(download_params)
    render :json => @download_data
  end

  def search_download_data
    @download_data = Trade::DownloadDataRetriever.search_download(download_params)
    render :json => @download_data
  end

  def search_download_all_data
    query = Trade::ComplianceGrouping.new('year', {attributes: sanitized_attributes, condition: "year = #{params[:year]}"})
    data = query.run
    search_data = query.build_hash(data, params)
    filtered_data = query.filter(search_data, params)
    data_ids = query.filter_download_data(filtered_data, params)
    hash_params = params_hash_builder(data_ids, download_params)
    @search_download_all_data = Trade::DownloadDataRetriever.search_download(hash_params)
    render :json => @search_download_all_data
  end

  private

  def params_hash_builder(ids, params)
    hash_params = {}
    hash_params[:ids] = ids.join(',')
    hash_params.merge!(params)
    hash_params.symbolize_keys
  end

  def metadata(data, params)
    {
      :total => data.count,
      :page => params[:page] || 1,
      :per_page => params[:per_page] || 25
    }
  end

  def search_params
    params.permit(:compliance_type, :time_range_start, :time_range_end, :page, :per_page)
  end

  def download_params
    params.permit(:year, :ids, :compliance_type, :type, :group_by)
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
