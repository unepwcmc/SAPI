class Api::V1::ShipmentsController < ApplicationController
  respond_to :json

  before_filter :authenticate
  before_filter :load_grouping_type
  after_filter only: [:grouped_query, :country_query] do
    set_pagination_headers(:data, :grouped_params)
  end

  #TODO
  def check_results
    query_data = Rails.cache.fetch([params[:query_type], params[:query_params]])

    if params[:query_type] == 'search' && query_data.present?
      query = @grouping_class.new(sanitized_attributes, params)
      @filtered_data = query.filter(query_data, params)
      render :json => Kaminari.paginate_array(@filtered_data).page(params[:page]).per(params[:per_page]),
            :meta => metadata(@filtered_data, params)
    else
      data = query_data.presence || { status: 'pending' }
      render :json => data
    end
  end

  def chart_query
    _attributes = ['issue_type', 'year']
    TradePlusWorker.perform_async('chart', @grouping_class, _attributes, params)

    #TODO
    render :json => { status: 'started' }
  
    # other possibility that makes use of the same request
    #if data.present?
    #  render json: data
    #elsif $redis.get_key([_attributes, params]).blank? # this is pseudocode
    #  TradePlusWorker.perform_async('chart', @grouping_class, _attributes, params)
    #  #TODO
    # render json: { status: 'started' }
    #else
    # render json: { status: 'pending' }
    #end
  end

  def grouped_query
    TradePlusWorker.perform_async('grouped', @grouping_class, sanitized_attributes, grouped_params)

    # TODO
    render :json => { status: 'started' }
  end

  def country_query
    TradePlusWorker.perform_async('country', @grouping_class, sanitized_attributes, grouped_params)

    # TODO
    render :json => { status: 'started' }
  end

  # Compliance tool search & full list action
  def search_query
    TradePlusWorker.perform_async('search', @grouping_class, sanitized_attributes, params)

    #TODO
    render json: { status: 'started' }
  end

  def over_time_query
    # TODO Remember to implement permitted parameters here
    TradePlusWorker.perform_async('over_time', @grouping_class, sanitized_attributes, params)

    # TODO
    render json: { status: 'started' }
  end

  def download_data
    @download_data = Rails.cache.fetch(['download_data', params], expires_in: 1.week) do
                       Trade::DownloadDataRetriever.dashboard_download(download_params).to_a
                     end
    render :json => @download_data
  end

  def search_download_data
    @download_data = Rails.cache.fetch(['search_download_data', params], expires_in: 1.week) do
                       Trade::DownloadDataRetriever.search_download(download_params).to_a
                     end
    render :json => @download_data
  end

  def search_download_all_data
    query = @grouping_class.new(sanitized_attributes, params)
    data = query.run
    @search_download_all_data = Rails.cache.fetch(['search_download_all_data', params], expires_in: 1.week) do
                                  search_data = query.build_hash(data, params)
                                  filtered_data = query.filter(search_data, params)
                                  data_ids = query.filter_download_data(filtered_data, params)
                                  hash_params = params_hash_builder(data_ids, download_params)
                                  Trade::DownloadDataRetriever.search_download(hash_params).to_a
                                end
    render :json => @search_download_all_data
  end

  private

  def set_pagination_headers(data, params)
    data = instance_variable_get("@#{data}").presence
    # Make sure the count works for both TradeView and ComplianceTool
    _count = data ? (data.first.is_a?(Array) ? data.count : data.first['total_count']) : 0
    params = send(params)
    response.headers['X-Total-Count'] = _count.to_s
    response.headers['X-Page'] = params[:page].to_s.presence || '1'
    response.headers['X-Per-Page'] = params[:per_page].to_s.presence || '25'
  end

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
    params.permit(:year, :ids, :compliance_type, :type, :group_by, :appendix)
  end

  def grouped_params
    params.permit(
      :compliance_type, :time_range_start, :time_range_end, :page, :per_page, :limit,
      :group_by, :grouping_type, :term_names, :term_ids, :purpose_names, :purpose_ids,
      :source_names, :source_ids, :unit_name, :unit_id, :appendices, :reported_by,
      :taxonomic_level, :taxonomic_group_name, :importer, :exporter, :origin, :taxon_id,
      :taxonomic_group, :country_ids, :reported_by_party, :unit_ids,
      :origin_ids, :importer_ids, :exporter_ids
    )
  end

  def sanitized_attributes
    @grouping_class.get_grouping_attributes(params[:group_by])
  end

  def authenticate
    token = request.headers['X-Authentication-Token']
    unless token == Rails.application.secrets["shipments_api_token"]
      head status: :unauthorized
      return false
    end
  end

  def load_grouping_type
    grouping_type = params[:grouping_type] || 'Compliance'
    begin
      @grouping_class = "Trade::Grouping::#{grouping_type.camelize}".constantize
    rescue NameError
      raise ArgumentError, 'Grouping type is not defined.'
    end
  end
end
