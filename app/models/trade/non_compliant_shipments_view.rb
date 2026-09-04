class Trade::NonCompliantShipmentsView < ApplicationRecord
  self.table_name = :non_compliant_shipments_view
  self.primary_key = :id
end
