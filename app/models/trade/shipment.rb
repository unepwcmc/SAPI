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
#  import_permit_number          :text
#  export_permit_number          :text
#  origin_permit_number          :text
#  legacy_shipment_number        :integer
#  import_permits_ids            :string
#  export_permits_ids            :string
#  origin_permits_ids            :string
#  updated_by_id                 :integer
#  created_by_id                 :integer
#

class Trade::Shipment < ActiveRecord::Base
  track_who_does_it
  attr_accessible :annual_report_upload_id, :appendix,
    :country_of_origin_id, :origin_permit_id,
    :exporter_id, :import_permit_id, :importer_id, :purpose_id,
    :quantity, :reporter_type, :reported_by_exporter,
    :source_id, :taxon_concept_id, :reported_taxon_concept_id,
    :term_id, :unit_id, :year,
    :import_permit_number, :export_permit_number, :origin_permit_number,
    :ignore_warnings, :created_by_id, :updated_by_id
  attr_accessor :reporter_type, :warnings, :ignore_warnings

  validates :quantity, :presence => true, :numericality => {
    :greater_than_or_equal_to => 0, :message => 'should be a positive number'
  }
  validates :appendix, :presence => true, :inclusion => {
    :in => ['I', 'II', 'III', 'N'], :message => 'should be one of I, II, III, N'
  }
  validates :year, :presence => true, :numericality => {
    :only_integer => true, :greater_than_or_equal_to => 1975, :less_than => 3000,
    :message => 'should be a 4 digit year'
  }
  validates :taxon_concept_id, :presence => true
  validates :term_id, :presence => true
  validates :exporter_id, :presence => true
  validates :importer_id, :presence => true
  validates :reporter_type, :presence => true, :inclusion => {
    :in => ['E', 'I'], :message => 'should be one of E, I'
  }
  validates_with Trade::ShipmentSecondaryErrorsValidator

  belongs_to :taxon_concept
  belongs_to :m_taxon_concept, :foreign_key => :taxon_concept_id
  belongs_to :reported_taxon_concept, :class_name => 'TaxonConcept'
  belongs_to :purpose, :class_name => "TradeCode"
  belongs_to :source, :class_name => "TradeCode"
  belongs_to :term, :class_name => "TradeCode"
  belongs_to :unit, :class_name => "TradeCode"
  belongs_to :country_of_origin, :class_name => "GeoEntity"
  belongs_to :exporter, :class_name => "GeoEntity"
  belongs_to :importer, :class_name => "GeoEntity"

  after_validation do
    unless self.errors.empty? && self.ignore_warnings
      # inject warnings here
      warnings.each { |w| self.errors[:warnings] << w }
    end
  end

  def self.reporter_type_to_reported_by_exporter(str)
    if str && str.upcase.strip == 'E'
      true
    elsif str && str.upcase.strip == 'I'
      false
    else
      nil
    end
  end

  def reporter_type
    return nil if reported_by_exporter.nil?
    reported_by_exporter ? 'E' : 'I'
  end

  def reporter_type=(str)
    self.reported_by_exporter = self.class.reporter_type_to_reported_by_exporter(str)
  end

  def import_permit_number=(str)
    set_permit_number('import', str)
  end

  def export_permit_number=(str)
    set_permit_number('export', str)
  end

  def origin_permit_number=(str)
    set_permit_number('origin', str)
  end

  def import_permits_ids
    read_attribute(:import_permits_ids) || []
  end

  def import_permits_ids=(ary)
    write_attribute(:import_permits_ids, "{#{ary && ary.join(',')}}")
  end

  def export_permits_ids
    read_attribute(:export_permits_ids) || []
  end

  def export_permits_ids=(ary)
    write_attribute(:export_permits_ids, "{#{ary && ary.join(',')}}")
  end

  def origin_permits_ids
    read_attribute(:origin_permits_ids) || []
  end

  def origin_permits_ids=(ary)
    write_attribute(:origin_permits_ids, "{#{ary && ary.join(',')}}")
  end

  def permits_ids
    (
      import_permits_ids + export_permits_ids + origin_permits_ids
    ).uniq.compact || []
  end

  private

  # note: this updates the precomputed fields
  # needs to be invoked via custom permit number setters
  # (import_permit_number=, export_permit_number=, origin_permit_number=)
  def set_permit_number(permit_type, str)
    permits = str && str.split(';').compact.map do |number|
      Trade::Permit.find_or_create_by(number: number.strip.upcase)
    end
    # save the concatenated permit numbers in the precomputed field
    write_attribute("#{permit_type}_permit_number", permits && permits.map(&:number).join(';'))
    # save the array of permit ids in the precomputed field
    send("#{permit_type}_permits_ids=", permits && permits.map(&:id))
  end

end
