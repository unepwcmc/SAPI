class Api::V1::TradePlusFiltersController < ApplicationController
  respond_to :json

  ATTRIBUTES = %w[importer exporter origin term
                  source purpose unit].freeze
  def index
    filters_service = Trade::TradePlusFilters
    filters = Rails.cache.fetch('trade_plus_filters', expires_in: 1.week) do
      res = ActiveRecord::Base.connection.execute(filters_service.query)
      filters_service.response_ordering(res)
    end

    render :json => filters
  end

  private

  def response_ordering(response)
    result = {}
    JSON.parse(response.first['filters']).each do |k, v|
      case k
      when 'sources', 'purposes'
        v.map do |value|
          value['id'], value['name'] = 'unreported', 'Unreported' if value['id'].nil?
        end
        v
      when 'units'
        v.map do |value|
          value['id'], value['name'] = 'items', 'Number of items' if value['id'].nil?
        end
        v
      when 'origins'
        v.map do |value|
          value['id'], value['iso2'], value['name'] = 'direct', 'direct', 'Direct' if value['id'].nil?
        end
        v
      when 'terms'
        v.map do |value|
          value['id'], value['name'] = value['id'].capitalize, value['name'].capitalize
        end
        v
      end
      result[k] = v.sort_by { |i| i['name'].to_s.downcase }
    end
    result
  end

  def query
    <<-SQL
     WITH data AS (
       SELECT #{select_query}
       FROM trade_plus_complete_mview
     )
     SELECT ROW_TO_JSON(t) AS filters
     FROM (
       SELECT #{inner_query}
       FROM data
     ) t
   SQL
  end

  def select_query
    query= []
    ATTRIBUTES.each do |attr|
      query << "#{attr}" << "#{attr}_id"
      query << "#{attr}_iso" if ['exporter', 'importer', 'origin'].include? attr
    end
    query << 'group_name' << 'year' << 'taxon_name' << 'taxon_id' << 'appendix'
    query.join(',')
  end

  def inner_query
    query = ''
    ATTRIBUTES.each do |attr|
      if %w[term unit].include? attr
        query << "json_agg(DISTINCT(json_build_object('name', #{attr}, 'id', #{attr})::jsonb)) AS #{attr.pluralize},"
      elsif %w[importer exporter origin].include? attr
        query << "json_agg(
                       DISTINCT(
                         json_build_object('name', #{attr}, 'id', #{attr}_id, 'iso2', #{attr}_iso)::jsonb
                       )
                     )
                    AS #{attr.pluralize},
                   "
      else
        query << "json_agg(
                       DISTINCT(
                         json_build_object('name', #{attr}, 'id', #{attr}_id)::jsonb
                       )
                     )
                    AS #{attr.pluralize},
                   "
      end

    end
    query << "json_agg(DISTINCT(json_build_object('name', taxon_name, 'id', taxon_id)::jsonb)) AS taxa,"
    query << "json_agg(DISTINCT(json_build_object('name', group_name, 'id', group_name)::jsonb)) AS taxonomic_groups,"
    query << "json_agg(DISTINCT(json_build_object('name', year, 'id', year)::jsonb)) AS years,"
    query << "json_agg(DISTINCT(json_build_object('name', appendix, 'id', appendix)::jsonb)) AS appendix"
    query
  end
end
