class Api::V1::TradePlusFiltersController < ApplicationController
  respond_to :json

  ATTRIBUTES = %w[importer exporter origin term
                  source purpose appendix unit].freeze
  def index
    res = ActiveRecord::Base.connection.execute(query)
    render :json => JSON.parse(res.first['filters'])
  end

  private

  def query
    <<-SQL
     WITH data AS (
       SELECT #{select_query}
       FROM trade_plus_static_complete_view
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
      query << "#{attr}_id" << "#{attr}"
      query << "#{attr}_iso" if ['exporter', 'importer', 'origin'].include? attr
    end
    query << 'group_name' << 'year' << 'taxon_name' << 'taxon_id'
    query.join(',')
  end

  def inner_query
    query = ''
    ATTRIBUTES.each do |attr|
      if %w[group_name term unit year].include? attr
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
    query << "json_agg(DISTINCT(json_build_object('name', taxon_name, 'id', taxon_id)::jsonb)) AS taxa"
    query
  end
end
