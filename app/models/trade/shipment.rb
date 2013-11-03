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
    :quantity, :reported_appendix, :reporter_type,
    :reported_species_name, :source_id, :taxon_concept_id,
    :term_id, :unit_id, :year,
    :import_permit_number, :export_permit_number, :country_of_origin_permit_number

  belongs_to :taxon_concept

  belongs_to :purpose, :class_name => "TradeCode"
  belongs_to :source, :class_name => "TradeCode"
  belongs_to :term, :class_name => "TradeCode"
  belongs_to :unit, :class_name => "TradeCode"

  belongs_to :country_of_origin, :class_name => "GeoEntity"
  belongs_to :exporter, :class_name => "GeoEntity"
  belongs_to :importer, :class_name => "GeoEntity"

  belongs_to :country_of_origin_permit, :class_name => "Trade::Permit"
  has_many :shipment_export_permits, :foreign_key => :trade_shipment_id, :class_name => "Trade::ShipmentExportPermit"
  has_many :export_permits, :through => :shipment_export_permits
  belongs_to :import_permit, :class_name => "Trade::Permit"

  def reporter_type
    reported_by_exporter ? 'E' : 'I'
  end

  def reporter_type=(str)
    self.reported_by_exporter = (str.upcase.strip == 'E' ? 'E' : 'I')
  end

  def import_permit_number
    import_permit && import_permit.number
  end

  def import_permit_number=(str)
    permit = Trade::Permit.find_or_create_by_number(str)
    self.import_permit = permit
  end

  def export_permit_number
    export_permits.map(&:number).join(';')
  end

  def export_permit_number=(str)
    permits = str.split(';').compact.map do |number|
      Trade::Permit.find_or_create_by_number(number)
    end
    self.export_permits = permits
  end

  def country_of_origin_permit_number
    country_of_origin_permit && country_of_origin_permit.number
  end

  def country_of_origin_permit_number=(str)
    permit = Trade::Permit.find_or_create_by_number(str)
    self.country_of_origin_permit = permit
  end
end
