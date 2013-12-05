# == Schema Information
#
# Table name: trade_shipment_export_permits
#
#  id                :integer          not null, primary key
#  trade_permit_id   :integer          not null
#  trade_shipment_id :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Trade::ShipmentExportPermit < ActiveRecord::Base #rename to: ShipmentExportPermit
  attr_accessible :trade_permit_id, :trade_shipment_id
  belongs_to :export_permit, :foreign_key => :trade_permit_id, :class_name => "Trade::Permit"
end
