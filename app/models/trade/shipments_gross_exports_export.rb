# Implements "gross exports" shipments export
class Trade::ShipmentsGrossExportsExport < Trade::ShipmentsComptabExport

private

  def table_name
    "trade_shipments_gross_exports_view"
  end

  def available_columns
    {
      :taxon => {},
      :taxon_concept_id => {:internal => true},
      :term => {:en => :term_name_en, :es => :term_name_es, :fr => :term_name_fr},
      :unit => {:en => :unit_name_en, :es => :unit_name_es, :fr => :unit_name_fr},
      :country => {},
      :year => {} #TODO
    }
  end

end
