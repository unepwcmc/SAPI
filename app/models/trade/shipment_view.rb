class Trade::ShipmentView < ActiveRecord::Base
  self.table_name = 'trade_shipments_view'
  belongs_to :taxon_concept
end