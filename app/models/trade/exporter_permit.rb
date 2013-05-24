# == Schema Information
#
# Table name: trade_exporter_permits
#
#  id                :integer          not null, primary key
#  trade_permit_id   :integer
#  trade_shipment_id :integer
#

class Trade::ExporterPermit < ActiveRecord::Base
  attr_accessible :trade_permit_id, :trade_shipment_id
end
