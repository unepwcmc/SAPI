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
#  country_of_origin_permit_id   :integer
#  import_permit_id              :integer
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
    :country_of_origin_id, :country_of_origin_permit_id,
    :exporter_id, :import_permit_id, :importer_id, :purpose_id,
    :quantity, :reporter_type,
    :source_id, :taxon_concept_id,
    :term_id, :unit_id, :year,
    :import_permit_number, :export_permit_number, :country_of_origin_permit_number,
    :ignore_warnings
  attr_accessor :reporter_type, :warnings, :ignore_warnings

  validates :quantity, presence: true, :numericality => {
    :message => 'should be a number'
  }
  validates :appendix, presence: true, :inclusion => { 
    :in => ['I', 'II', 'III'], :message => 'should be one of I, II, III' 
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
  belongs_to :country_of_origin_permit, :class_name => "Trade::Permit"
  has_many :shipment_export_permits, :foreign_key => :trade_shipment_id,
    :class_name => "Trade::ShipmentExportPermit", :dependent => :destroy
  has_many :export_permits, :through => :shipment_export_permits
  belongs_to :import_permit, :class_name => "Trade::Permit"

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
    self['import_permit_number'] || import_permit && import_permit.number
  end

  def import_permit_number=(str)
    if str
      permit = Trade::Permit.find_or_create_by_number(str)
      self.import_permit = permit
    end
  end

  def export_permit_number
    self['export_permit_number'] || export_permits.map(&:number).join(';')
  end

  def export_permit_number=(str)
    if str
      permits = str.split(';').compact.map do |number|
        Trade::Permit.find_or_create_by_number(number)
      end
      self.export_permits = permits
    end
  end

  def country_of_origin_permit_number
    self['country_of_origin_permit_number'] ||  country_of_origin_permit && country_of_origin_permit.number
  end

  def country_of_origin_permit_number=(str)
    if str
      permit = Trade::Permit.find_or_create_by_number(str)
      self.country_of_origin_permit = permit
    end
  end

end
