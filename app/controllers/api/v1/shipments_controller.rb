class Api::V1::ShipmentsController < ApplicationController
  respond_to :json

  before_filter :authenticate
  before_filter :load_grouping_type

  def index
    @search = Trade::Filter.new(search_params)
    render :json => @search.results,
      :each_serializer => Trade::ShipmentApiComplianceSerializer,
      :meta => metadata_for_search(@search)
  end

  def chart_query
    @chart_data = Rails.cache.fetch(['chart_data', params], expires_in: 1.week) do
                    @grouping_class.new(['issue_type', 'year'])
                                             .countries_reported_range(params[:year])
                  end
    render :json => @chart_data
  end

  def grouped_query
    limit = grouped_params[:limit].present? ? grouped_params[:limit].to_i : ''
    year_start = grouped_params[:time_range_start] || 2012
    year_end = grouped_params[:time_range_end] || Date.today.year - 1
    years_range = "year >= #{year_start} AND year <= #{year_end}"

    query = @grouping_class.new(sanitized_attributes, {condition: years_range, limit: limit})
    data = query.run
    params_hash = { attribute: 'year' }
    sanitized_attributes.map { |p| params_hash[p] = p }
    @grouped_data = Rails.cache.fetch(['grouped_data', grouped_params], expires_in: 1.week) do
                      sanitized_attributes.first.empty? ? query.taxonomic_grouping :
                                                          query.json_by_attribute(data, params_hash)
                    end
    render :json =>  @grouped_data
  end

  def search_query
    query = @grouping_class.new(sanitized_attributes, {condition: "year = #{params[:year]}"})
    data = query.run
    @search_data =  Rails.cache.fetch(['search_data', params], expires_in: 1.week) do
                      query.build_hash(data, params)
                    end
    @filtered_data = query.filter(@search_data, params)
    render :json => Kaminari.paginate_array(@filtered_data).page(params[:page]).per(params[:per_page]),
           :meta => metadata(@filtered_data, params)
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
    query = @grouping_class.new(sanitized_attributes, {condition: "year = #{params[:year]}"})
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
      :group_by, :grouping_type
    )
  end

  def sanitized_attributes
    @grouping_class.get_grouping_attributes(params[:group_by])
  end

  def authenticate
    token = request.headers['X-Authentication-Token']
    unless token == Rails.application.secrets["compliance_tool_token"]
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
