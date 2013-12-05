# Implements "comptab" shipments export
class Trade::ShipmentsComptabExport < Trade::ShipmentsExport

  def initialize(filters = {})
    @filters = filters || {}
    @search = Trade::Filter.new(
      @filters,
      Trade::Shipment.from('trade_shipments_comptab_view trade_shipments')
    )
  end

  def query
    headers = csv_column_headers
    select_columns = sql_columns.each_with_index.map do |c, i|
      "#{c} AS \\\"#{headers[i]}\\\""
    end
    @search.query.select(select_columns)
  end

private

  def table_name
    "trade_shipments_comptab_view"
  end

  def available_columns
    {
      :year => {},
      :appendix => {},
      :family => {},
      :taxon => {},
      :taxon_concept_id => {:internal => true},
      :importer => {},
      :exporter => {},
      :country_of_origin => {},
      :importer_quantity => {},
      :exporter_quantity => {},
      :term => {:en => :term_name_en, :es => :term_name_es, :fr => :term_name_fr},
      :unit => {:en => :unit_name_en, :es => :unit_name_es, :fr => :unit_name_fr},
      :purpose => {},
      :source => {}
    }
  end

end
