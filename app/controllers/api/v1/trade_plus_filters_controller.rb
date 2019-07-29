class Api::V1::TradePlusFiltersController < ApplicationController
  ATTRIBUTES = %w[taxon importer exporter origin term
                  source purpose appendix unit].freeze
  def index
    query = <<-SQL
      WITH data AS (
        SELECT #{select_query}
        FROM trade_plus_static_complete_view
      )#{inner_query}
      #{agg_query}
      SELECT ARRAY_TO_JSON(ARRAY_AGG_NOTNULL(DISTINCT group_name)) AS groups
      FROM data
      UNION
      SELECT ARRAY_TO_JSON(ARRAY_AGG_NOTNULL(DISTINCT year)) AS years
      FROM data
    SQL
    byebug
    res = ActiveRecord::Base.connection.execute(query)
    puts res.first
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
    ATTRIBUTES.each do |attr|
      query << ", #{attr} AS (
                  SELECT DISTINCT #{attr}_id, #{attr}
                  FROM data
                )
              "
    end
    query
  end

  def agg_query
    query= ''
    ATTRIBUTES.each do |attr|
      query << "SELECT JSON_AGG(#{attr}.*) AS #{attr.pluralize}
                FROM #{attr}
                WHERE #{attr} IS NOT NULL
                UNION
               "
    end
    query
  end
end
