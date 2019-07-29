class Api::V1::TradePlusFiltersController < ApplicationController
  respond_to :json

  ATTRIBUTES = %w[taxon importer exporter origin term
                  source purpose appendix unit].freeze
  def index
    query = <<-SQL
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
    res = ActiveRecord::Base.connection.execute(query)
    render :json => JSON.parse(res.first['filters'])
  end

  private

  def select_query
    query= []
    ATTRIBUTES.each do |attr|
      query << "#{attr}_id" << "#{attr}"
    end
    query << 'group_name' << 'year'
    query.join(',')
  end

  def inner_query
    query = ''
    ATTRIBUTES.reject{ |i| ['taxon', 'term', 'unit'].include? i }.each do |attr|
      query << "json_agg(
                  DISTINCT(
                    json_build_object('#{attr}', #{attr}, '#{attr}_id', #{attr}_id)::jsonb
                  )
                )
               AS #{attr.pluralize},
              "
    end
    query << "json_agg(DISTINCT(json_build_object('taxon', taxon, 'taxon_id', taxon_id)::jsonb)) AS taxa,"
    query << "json_agg(DISTINCT(json_build_object('term', term)::jsonb)) AS terms,"
    query << "json_agg(DISTINCT(json_build_object('unit', unit)::jsonb)) AS units,"
    query << "json_agg(DISTINCT(json_build_object('group_name', group_name)::jsonb)) AS group_names,"
    query << "json_agg(DISTINCT(json_build_object('year', year)::jsonb)) AS years"
    query
  end
end
