# == Schema Information
#
# Table name: trade_shipments
#
#  id                            :integer          not null, primary key
#  source_id                     :integer
#  unit_id                       :integer
#  purpose_id                    :integer
#  term_id                       :integer
#  quantity                      :decimal(, )
#  reported_appendix             :string(255)
#  appendix                      :string(255)
#  trade_annual_report_upload_id :integer
#  exporter_id                   :integer
#  importer_id                   :integer
#  country_of_origin_id          :integer
#  country_of_origin_permit_id   :integer
#  import_permit_id              :integer
#  reported_by_exporter          :boolean
#  taxon_concept_id              :integer
#  reported_species_name         :string(255)
#  year                          :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  sandbox_id                    :integer
#

class Trade::Shipment < ActiveRecord::Base
  attr_accessible :annual_report_upload_id, :appendix,
    :country_of_origin_id, :country_of_origin_permit_id,
    :exporter_id, :import_permit_id, :importer_id, :purpose_id,
    :quantity, :reported_appendix, :reported_by_exporter,
    :reported_species_name, :source_id, :taxon_concept_id,
    :term_id, :unit_id, :year

  belongs_to :taxon_concept

  belongs_to :purpose, :class_name => "TradeCode"
  belongs_to :source, :class_name => "TradeCode"
  belongs_to :term, :class_name => "TradeCode"
  belongs_to :unit, :class_name => "TradeCode"

  belongs_to :country_of_origin, :class_name => "GeoEntity"
  belongs_to :exporter, :class_name => "GeoEntity"
  belongs_to :importer, :class_name => "GeoEntity"

  belongs_to :country_of_origin_permit, :class_name => "Trade::Permit"
  belongs_to :export_permit, :class_name => "Trade::Permit"
  belongs_to :import_permit, :class_name => "Trade::Permit"
end
