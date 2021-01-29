class TradePlusWorker
  include Sidekiq::Worker

  def perform(query_type, grouping_class, attributes, params)
    query_name = "#{query_type}_query".to_sym
    cache_key_name = "#{query_type}_data"
    _params = params

    if %w(grouped country).include?(query_type)
      limit = params[:limit].present? ? params[:limit].to_i : ''
      _params = params.merge(limit: limit, with_defaults: true)
    end

    Rails.cache.fetch([cache_key_name, _params], expires_in: 1.week) do
      send(query_name, grouping_class, attributes, _params)
    end
  end

  private

  def chart_query(grouping_class, attributes, params)
    grouping_class.new(['issue_type', 'year'])
      .countries_reported_range(params[:year])
  end

  def grouped_query(grouping_class, attributes, params)
    taxonomic_params = {
      taxonomic_level: params[:taxonomic_level],
      group_name: params[:group_name]
    }
    query = grouping_class.new(attributes, params)
    params_hash = { attribute: 'year' }
    attributes.map { |p| params_hash[p] = p }

    if attributes.first.empty?
      query.taxonomic_grouping(taxonomic_params)
    else
      query.json_by_attribute(query.run, params_hash)
    end
  end

  def country_query(grouping_class, attributes, params)
    taxonomic_params = {
      taxonomic_level: params[:taxonomic_level],
      group_name: params[:group_name]
    }
    query = grouping_class.new(attributes, params)
    params_hash = { attribute: 'year' }
    attributes.map { |p| params_hash[p] = p }
    if sanitized_attributes.first.empty?
      query.taxonomic_grouping(taxonomic_params)
    else
      query.json_by_attribute(query.country_data, params_hash)
    end
  end

  def search_query(grouping_class, attributes, params)
    query = grouping_class.new(attributes, params)
    data = query.run
    query.build_hash(data, params)
  end

  def over_time_query(grouping_class, attributes, params)
    query = grouping_class.new(attributes, params)
    query.over_time_data
  end
end
