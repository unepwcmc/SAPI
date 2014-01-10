# == Schema Information
#
# Table name: trade_shipments
#
#  id                            :integer          not null, primary key
#  source_id                     :integer
#  unit_id                       :integer
#  purpose_id                    :integer
#  term_id                       :integer          not null
#  quantity                      :decimal(, )      not null
#  appendix                      :string(255)      not null
#  trade_annual_report_upload_id :integer
#  exporter_id                   :integer          not null
#  importer_id                   :integer          not null
#  country_of_origin_id          :integer
#  reported_by_exporter          :boolean          default(TRUE), not null
#  taxon_concept_id              :integer          not null
#  year                          :integer          not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  sandbox_id                    :integer
#  reported_taxon_concept_id     :integer
#

class Trade::Shipment < ActiveRecord::Base
  attr_accessible :annual_report_upload_id, :appendix,
    :country_of_origin_id, :origin_permit_id,
    :exporter_id, :import_permit_id, :importer_id, :purpose_id,
    :quantity, :reporter_type,
    :source_id, :taxon_concept_id,
    :term_id, :unit_id, :year,
    :import_permit_number, :export_permit_number, :origin_permit_number,
    :ignore_warnings
  attr_accessor :reporter_type, :warnings, :ignore_warnings

  validates :quantity, presence: true, :numericality => {
    :greater_than_or_equal_to => 0, :message => 'should be a positive number'
  }
  validates :appendix, presence: true, :inclusion => {
    :in => ['I', 'II', 'III', 'N'], :message => 'should be one of I, II, III, N'
  }
  validates :year, presence: true, :numericality => {
    :only_integer => true, :greater_than_or_equal_to => 1975, :less_than => 3000,
    :message => 'should be a 4 digit year'
  }
  validates :taxon_concept_id, presence: true
  validates :term_id, presence: true
  validates :exporter_id, presence: true
  validates :importer_id, presence: true
  validates :reporter_type, presence: true, :inclusion => {
    :in => ['E', 'I'], :message => 'should be one of E, I'
  }
  validates :country_of_origin, :presence => true,
    :unless => Proc.new { |s| s.origin_permit_number.blank? }
  validates_with Trade::ShipmentSecondaryErrorsValidator

  belongs_to :taxon_concept
  belongs_to :reported_taxon_concept, :class_name => 'TaxonConcept'
  belongs_to :purpose, :class_name => "TradeCode"
  belongs_to :source, :class_name => "TradeCode"
  belongs_to :term, :class_name => "TradeCode"
  belongs_to :unit, :class_name => "TradeCode"
  belongs_to :country_of_origin, :class_name => "GeoEntity"
  belongs_to :exporter, :class_name => "GeoEntity"
  belongs_to :importer, :class_name => "GeoEntity"
  has_many :shipment_import_permits, :foreign_key => :trade_shipment_id,
    :class_name => "Trade::ShipmentImportPermit", :dependent => :destroy
  has_many :import_permits, :through => :shipment_import_permits
  has_many :shipment_export_permits, :foreign_key => :trade_shipment_id,
    :class_name => "Trade::ShipmentExportPermit", :dependent => :destroy
  has_many :export_permits, :through => :shipment_export_permits
  has_many :shipment_origin_permits, :foreign_key => :trade_shipment_id,
    :class_name => "Trade::ShipmentOriginPermit", :dependent => :destroy
  has_many :origin_permits, :through => :shipment_origin_permits

  after_validation do
    unless self.errors.empty? && self.ignore_warnings
      #inject warnings here
      warnings.each { |w| self.errors[:warnings] << w }
    end
  end

  def reporter_type
    return nil if reported_by_exporter.nil?
    reported_by_exporter ? 'E' : 'I'
  end

  def reporter_type=(str)
    self.reported_by_exporter = if str && str.upcase.strip == 'E'
      true
    elsif str && str.upcase.strip == 'I'
      false
    else
      nil
    end
  end

  def import_permit_number
    get_permit_number('import')
  end

  def import_permit_number=(str)
    set_permit_number('import', str, self.importer_id)
  end

  def export_permit_number
    get_permit_number('export')
  end

  def export_permit_number=(str)
    set_permit_number('export', str, self.exporter_id)
  end

  def origin_permit_number
    get_permit_number('origin')
  end

  def origin_permit_number=(str)
    set_permit_number('origin', str, self.country_of_origin_id)
  end

  private
  def get_permit_number(permit_type)
    self["#{permit_type}_permit_number"] || self.send("#{permit_type}_permits").map(&:number).join(';')
  end

  def set_permit_number(permit_type, str, geo_entity_id)
    if str
      permits = str.split(';').compact.map do |number|
        Trade::Permit.find_or_create_by_number_and_geo_entity_id(number, geo_entity_id)
      end
      self.send("#{permit_type}_permits=", permits)
    end
  end

end
