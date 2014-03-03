# Implements "comptab" shipments export
class Trade::ShipmentsComptabExport < Trade::ShipmentsExport
  include Trade::ShipmentReportQueries

  def total_cnt
    ActiveRecord::Base.connection.execute(query_sql(:limit => false)).ntuples
  end

  def query
    ActiveRecord::Base.connection.execute(query_sql(:limit => true))
  end

private

  def query_sql(options)
    headers = csv_column_headers
    select_columns = sql_columns.each_with_index.map do |c, i|
      "#{c} AS \"#{headers[i]}\""
    end
    "SELECT #{select_columns.join(', ')} FROM (#{subquery_sql(options)}) subquery"
  end

  def subquery_sql(options)
    comptab_query(options)
  end

  def resource_name
    "comptab"
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
