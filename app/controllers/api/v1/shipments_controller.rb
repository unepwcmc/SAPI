# Used by:
#
# https://github.com/unepwcmc/cites-compliance-tool/blob/master/lib/modules/shipments_api_retriever.rb
# https://github.com/unepwcmc/tradeplus/blob/master/lib/modules/shipments_api_retriever.rb
# https://github.com/unepwcmc/sustainability-assessment-tool/blob/main/rails-api/lib/modules/sapi_api.rb

class Api::V1::ShipmentsController < ApplicationController
  respond_to :json

  before_action :authenticate
  before_action :load_grouping_type
  after_action only: [ :grouped_query, :country_query ] do
    set_pagination_headers(:data, :grouped_params)
  end

  def chart_query
    @chart_data =
      Rails.cache.fetch(
        [ 'chart_data', params_unsafely_permitted ],
        expires_in: 1.week
      ) do
        @grouping_class.new(
          {
            group_by: 'issue_type'
          }
        ).countries_reported_range(params[:year])
      end

    render json: @chart_data
  end

  def grouped_query
    limit = grouped_params[:limit].present? ? grouped_params[:limit].to_i : ''

    _grouped_params = grouped_params.merge(limit: limit, with_defaults: true)

    taxonomic_params = {
      taxonomic_level: grouped_params[:taxonomic_level],
      group_name: grouped_params[:group_name]
    }

    @grouping_instance = @grouping_class.new(_grouped_params)

    params_hash = { attribute: 'year' }

    @grouping_instance.grouping_attribute_names.map { |p| params_hash[p] = p }

    @data =
      Rails.cache.fetch(
        [ 'grouped_data', grouped_params ], expires_in: 1.week
      ) do
        if 'taxonomy' == grouped_params[:group_by]
          @grouping_instance.taxonomic_grouping(taxonomic_params)
        else
          @grouping_instance.json_by_attribute(@grouping_instance.run, params_hash)
        end
      end

    render json: @data
  end

  def country_query
    # This does not work for the Compliance grouping class
    @grouping_class = Trade::Grouping::TradePlusStatic

    limit = grouped_params[:limit].present? ? grouped_params[:limit].to_i : ''
    _grouped_params = grouped_params.merge(limit: limit, with_defaults: true)
    taxonomic_params = {
      taxonomic_level: grouped_params[:taxonomic_level],
      group_name: grouped_params[:group_name]
    }

    @grouping_instance = @grouping_class.new(_grouped_params)

    params_hash = { attribute: 'year' }

    @grouping_instance.grouping_attribute_names.map { |p| params_hash[p] = p }

    @data =
      Rails.cache.fetch(
        [ 'country_data', grouped_params ],
        expires_in: 1.week
      ) do
        if 'taxonomy' == grouped_params[:group_by]
          @grouping_instance.taxonomic_grouping(taxonomic_params)
        else
          @grouping_instance.json_by_attribute(@grouping_instance.country_data, params_hash)
        end
      end

    render json: @data
  end

  # Compliance tool search & full list action
  def search_query
    @grouping_instance = @grouping_class.new(params_unsafely_permitted)
    data = @grouping_instance.run
    @search_data =
      Rails.cache.fetch(
        [ 'search_data', params_unsafely_permitted ],
        expires_in: 1.week
      ) do
        @grouping_instance.build_hash(data, params_unsafely_permitted)
      end

    @filtered_data = @grouping_instance.filter(@search_data, params_unsafely_permitted) || []

    render json:
      Kaminari.paginate_array(@filtered_data).page(
        params[:page]
      ).per(
        params[:per_page]
      ),
      meta: metadata(@filtered_data, params_unsafely_permitted)
  end

  def over_time_query
    # This does not work for the Compliance grouping class
    @grouping_class = Trade::Grouping::TradePlusStatic

    # TODO Remember to implement permitted parameters here
    @grouping_instance = @grouping_class.new(params_unsafely_permitted)

    @over_time_data =
      Rails.cache.fetch(
        [ 'over_time_data', params_unsafely_permitted ], expires_in: 1.week
      ) do
        @grouping_instance.over_time_data
      end

    render json: @over_time_data
  end

  # TODO refactor to merge this method and the over_time one above together
  def aggregated_over_time_query
    # This does not work for the Compliance grouping class
    @grouping_class = Trade::Grouping::TradePlusStatic

    # TODO Remember to implement permitted parameters here
    @grouping_instance = @grouping_class.new(params_unsafely_permitted)

    @aggregated_over_time_data =
      Rails.cache.fetch(
        [ 'aggregated_over_time_data', params_unsafely_permitted ],
        expires_in: 1.week
      ) do
        @grouping_instance.aggregated_over_time_data
      end

    render json: @aggregated_over_time_data
  end

  def download_data
    @download_data =
      Rails.cache.fetch(
        [ 'download_data', params_unsafely_permitted ], expires_in: 1.week
      ) do
        Trade::DownloadDataRetriever.dashboard_download(download_params).to_a
      end
    render json: @download_data
  end

  def search_download_data
    @download_data =
      Rails.cache.fetch(
        [ 'search_download_data', params_unsafely_permitted ], expires_in: 1.week
      ) do
        Trade::DownloadDataRetriever.search_download(download_params).to_a
      end

    render json: @download_data
  end

  def search_download_all_data
    @grouping_instance = @grouping_class.new(params_unsafely_permitted)

    data = @grouping_instance.run

    @search_download_all_data =
      Rails.cache.fetch(
        [ 'search_download_all_data', params_unsafely_permitted ], expires_in: 1.week
      ) do
        search_data = @grouping_instance.build_hash(data, params_unsafely_permitted)
        filtered_data = @grouping_instance.filter(search_data, params_unsafely_permitted)
        data_ids = @grouping_instance.filter_download_data(filtered_data, params_unsafely_permitted)
        hash_params = params_hash_builder(data_ids, download_params)

        Trade::DownloadDataRetriever.search_download(hash_params).to_a
      end

    render json: @search_download_all_data
  end

private

  def params_unsafely_permitted
    params.permit!
  end

  def set_pagination_headers(data, params)
    data = instance_variable_get("@#{data}").presence

    # Make sure the count works for both TradeView and ComplianceTool
    _count =
      if data
        if data.first.is_a?(Array)
          data.count
        else
          data.first['total_count']
        end
      else
        0
      end

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
      total: data.count,
      page: params[:page] || 1,
      per_page: params[:per_page] || 25
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
      :origin_ids, :importer_ids, :exporter_ids, :locale,
      :call, :grouping, :format
    )
  end

  def authenticate
    token = request.headers['X-Authentication-Token']

    unless token == Rails.application.credentials.dig(:shipments_api_token)
      head :unauthorized

      false
    end
  end

  def load_grouping_type
    @grouping_class =
      if params[:grouping_type] == 'TradePlus'
        Trade::Grouping::TradePlus
      elsif params[:grouping_type] == 'TradePlusStatic'
        Trade::Grouping::TradePlusStatic
      else
        Trade::Grouping::Compliance
      end
  end
end
