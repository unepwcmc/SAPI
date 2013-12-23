# == Schema Information
#
# Table name: trade_shipment_import_permits
#
#  id                :integer          not null, primary key
#  trade_permit_id   :integer          not null
#  trade_shipment_id :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Trade::ShipmentImportPermit < ActiveRecord::Base
  attr_accessible :trade_permit_id, :trade_shipment_id
  belongs_to :import_permit, :foreign_key => :trade_permit_id, :class_name => "Trade::Permit"
  validates :trade_permit_id, :uniqueness => {:scope => :trade_shipment_id}
end
