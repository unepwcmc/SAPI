class Api::V1::ShipmentsController < ApplicationController
  respond_to :json

  before_filter :authenticate

  GROUPING_ATTRIBUTES = {
    category: ['issue_type'],
    commodity: ['term'],
    exporting: ['exporter', 'exporter_iso', 'exporter_id'],
    importing: ['importer', 'importer_iso', 'importer_id'],
    species: ['taxon_name', 'appendix'],
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
    temp_data = sanitized_attributes.first.empty? ? query.taxonomic_grouping :
                                                    query.json_by_year(data, params_hash)
    render :json => sanitized_data(temp_data)
  end

  def search_query
    query = Trade::ComplianceGrouping.new('year', {attributes: sanitized_attributes, condition: "year = #{params[:year]}"})
    data = query.run
    @search_data = build_hash(data)
    render :json => @search_data
  end

  private

  def search_params
    params.permit(:compliance_type, :time_range_start, :time_range_end, :page, :per_page)
  end

  def sanitized_attributes
    GROUPING_ATTRIBUTES[params[:group_by].to_sym]
  end

  def sanitized_data(data)
    if params[:group_by].include?('category') || params[:group_by].include?('taxonomy')
      @grouped_data = data
    else
      record = {}
      data.each do |d|
        key = d.keys.first
        record[key] = d[key][0..4]
      end
      @grouped_data = record
    end
    @grouped_data
  end

  def build_hash(data)
    hash, json = {}, []
    if params[:group_by].include?('commodity')
      keys = data.values.map { |d| d[1] }.uniq
      keys.map do |k|
        partial = data.values.select { |d| d[1] == k }
        values = partial.map { |el| hash.merge({ cnt: el[2].to_i }) }
        json << ({ "#{k}": values[0] })
      end
    elsif params[:group_by].include?('exporting')
      query = Trade::ComplianceGrouping.new('year', {attributes: GROUPING_ATTRIBUTES[:importing], condition: "year = #{params[:year]}"}).run
      all_data = data.values + query.values
      keys = all_data.map { |d| d[1] }.uniq
      keys.map do |k|
        exp_partial = data.values.select { |d| d[1] == k }
        exp_values = exp_partial.map do |el|
          id = el[3]
          tot_exp = total_ships_exp_cnt(id)
          hash.merge({
            cnt: el[4].to_i,
            total_cnt: tot_exp
          })
        end
        imp_partial = query.values.select { |d| d[1] == k }
        imp_values = imp_partial.map do |el|
          id = el[3]
          tot_imp = total_ships_imp_cnt(id)
          hash.merge({
            cnt: el[4].to_i,
            total_cnt: tot_imp
          })
        end
        values = if exp_values.empty?
                   imp_values[0]
                 elsif imp_values.empty?
                   exp_values[0]
                 else
                   exp_values[0].merge(imp_values[0]){ |_x, a, b| a + b }
                 end
        values = values.merge(percentage: (values[:cnt]*100.0/values[:total_cnt]).round(2))
        json << ({ "#{k}": values })
      end
    else
      keys = data.values.map { |d| d[1] }.uniq
      keys.map do |k|
        partial = data.values.select { |d| d[1] == k }
        values = partial.map { |el| hash.merge({ appendix: el[2], cnt: el[3].to_i }) }
        json << ({ "#{k}": values[0] })
      end
    end
    json
  end

  def total_ships_exp_cnt(id)
    query_exp = "SELECT COUNT(*) FROM trade_shipments_with_taxa_view WHERE exporter_id = #{id} GROUP BY exporter_id"
    ActiveRecord::Base.connection.execute(query_exp).values.flatten.first.to_i
  end

  def total_ships_imp_cnt(id)
    query_imp = "SELECT COUNT(*) FROM trade_shipments_with_taxa_view WHERE importer_id = #{id} GROUP BY importer_id"
    ActiveRecord::Base.connection.execute(query_imp).values.flatten.first.to_i
  end

  def authenticate
    token = request.headers['X-Authentication-Token']
    unless token == Rails.application.secrets["compliance_tool_token"]
      head status: :unauthorized
      return false
    end
  end
end
