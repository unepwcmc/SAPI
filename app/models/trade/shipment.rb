# == Schema Information
#
# Table name: trade_shipments
#
#  id                            :integer          not null, primary key
#  appendix                      :string(255)      not null
#  epix_created_at               :datetime
#  epix_updated_at               :datetime
#  export_permit_number          :text
#  export_permits_ids            :integer          is an Array
#  ifs_permit_number             :text
#  ifs_permits_ids               :integer          is an Array
#  import_permit_number          :text
#  import_permits_ids            :integer          is an Array
#  legacy_shipment_number        :integer
#  origin_permit_number          :text
#  origin_permits_ids            :integer          is an Array
#  quantity                      :decimal(, )      not null
#  reported_by_exporter          :boolean          default(TRUE), not null
#  year                          :integer          not null
#  created_at                    :datetime
#  updated_at                    :datetime
#  country_of_origin_id          :integer
#  created_by_id                 :integer
#  epix_created_by_id            :integer
#  epix_updated_by_id            :integer
#  exporter_id                   :integer          not null
#  importer_id                   :integer          not null
#  purpose_id                    :integer
#  reported_taxon_concept_id     :integer
#  sandbox_id                    :integer
#  source_id                     :integer
#  taxon_concept_id              :integer          not null
#  term_id                       :integer          not null
#  trade_annual_report_upload_id :integer
#  unit_id                       :integer
#  updated_by_id                 :integer
#
# Indexes
#
#  index_trade_shipments_on_appendix                         (appendix)
#  index_trade_shipments_on_country_of_origin_id             (country_of_origin_id)
#  index_trade_shipments_on_created_by_id                    (created_by_id)
#  index_trade_shipments_on_created_by_id_and_updated_by_id  (created_by_id,updated_by_id)
#  index_trade_shipments_on_export_permits_ids               (export_permits_ids) USING gin
#  index_trade_shipments_on_exporter_id                      (exporter_id)
#  index_trade_shipments_on_ifs_permits_ids                  (ifs_permits_ids) USING gin
#  index_trade_shipments_on_import_permits_ids               (import_permits_ids) USING gin
#  index_trade_shipments_on_importer_id                      (importer_id)
#  index_trade_shipments_on_origin_permits_ids               (origin_permits_ids) USING gin
#  index_trade_shipments_on_purpose_id                       (purpose_id)
#  index_trade_shipments_on_quantity                         (quantity)
#  index_trade_shipments_on_reported_taxon_concept_id        (reported_taxon_concept_id)
#  index_trade_shipments_on_sandbox_id                       (sandbox_id)
#  index_trade_shipments_on_source_id                        (source_id)
#  index_trade_shipments_on_taxon_concept_id                 (taxon_concept_id)
#  index_trade_shipments_on_term_id                          (term_id)
#  index_trade_shipments_on_trade_annual_report_upload_id    (trade_annual_report_upload_id)
#  index_trade_shipments_on_unit_id                          (unit_id)
#  index_trade_shipments_on_updated_by_id                    (updated_by_id)
#  index_trade_shipments_on_year                             (year)
#  index_trade_shipments_on_year_exporter_id                 (year,exporter_id)
#  index_trade_shipments_on_year_importer_id                 (year,importer_id)
#
# Foreign Keys
#
#  trade_shipments_country_of_origin_id_fk           (country_of_origin_id => geo_entities.id)
#  trade_shipments_created_by_id_fk                  (created_by_id => users.id)
#  trade_shipments_exporter_id_fk                    (exporter_id => geo_entities.id)
#  trade_shipments_importer_id_fk                    (importer_id => geo_entities.id)
#  trade_shipments_purpose_id_fk                     (purpose_id => trade_codes.id)
#  trade_shipments_reported_taxon_concept_id_fk      (reported_taxon_concept_id => taxon_concepts.id)
#  trade_shipments_source_id_fk                      (source_id => trade_codes.id)
#  trade_shipments_taxon_concept_id_fk               (taxon_concept_id => taxon_concepts.id)
#  trade_shipments_term_id_fk                        (term_id => trade_codes.id)
#  trade_shipments_trade_annual_report_upload_id_fk  (trade_annual_report_upload_id => trade_annual_report_uploads.id)
#  trade_shipments_unit_id_fk                        (unit_id => trade_codes.id)
#  trade_shipments_updated_by_id_fk                  (updated_by_id => users.id)
#

class Trade::Shipment < ApplicationRecord
  include TrackWhoDoesIt
  # Not sure where using this.
  # attr_accessible :annual_report_upload_id, :appendix,
  #   :country_of_origin_id, :origin_permit_id,
  #   :exporter_id, :import_permit_id, :importer_id, :purpose_id,
  #   :quantity, :reporter_type, :reported_by_exporter,
  #   :source_id, :taxon_concept_id, :reported_taxon_concept_id,
  #   :term_id, :unit_id, :year,
  #   :import_permit_number, :export_permit_number, :origin_permit_number,
  #   :ignore_warnings, :created_by_id, :updated_by_id

  attr_accessor :reporter_type, :warnings, :ignore_warnings

  validates :quantity, presence: true, numericality: {
    greater_than_or_equal_to: 0, message: 'should be a positive number'
  }
  validates :appendix, presence: true, inclusion: {
    in: [ 'I', 'II', 'III', 'N' ], message: 'should be one of I, II, III, N'
  }
  validates :year, presence: true, numericality: {
    only_integer: true, greater_than_or_equal_to: 1975, less_than: 3000,
    message: 'should be a 4 digit year'
  }
  validates :reporter_type, presence: true, inclusion: {
    in: [ 'E', 'I' ], message: 'should be one of E, I'
  }
  validates_with Trade::ShipmentSecondaryErrorsValidator

  belongs_to :taxon_concept
  belongs_to :m_taxon_concept, foreign_key: :taxon_concept_id, optional: true
  belongs_to :reported_taxon_concept, class_name: 'TaxonConcept', optional: true
  belongs_to :purpose, class_name: 'TradeCode', optional: true
  belongs_to :source, class_name: 'TradeCode', optional: true
  belongs_to :term, class_name: 'TradeCode'
  belongs_to :unit, class_name: 'TradeCode', optional: true
  belongs_to :country_of_origin, class_name: 'GeoEntity', optional: true
  belongs_to :exporter, class_name: 'GeoEntity'
  belongs_to :importer, class_name: 'GeoEntity'

  before_save do
    @old_permits_ids = []
    [
      import_permits_ids_was,
      export_permits_ids_was,
      origin_permits_ids_was,
      ifs_permits_ids_was
    ].each do |permits_ids|
      @old_permits_ids += permits_ids ? permits_ids.dup : []
    end
    unless reported_taxon_concept_id
      self.reported_taxon_concept_id = taxon_concept_id
    end
  end
  before_destroy do
    @old_permits_ids = permits_ids.dup
  end
  after_commit :async_tasks_after_save, on: [ :create, :update ]
  after_commit :async_tasks_for_destroy, on: :destroy

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

  def ifs_permits_ids
    read_attribute(:ifs_permits_ids) || []
  end

  def ifs_permits_ids=(ary)
    write_attribute(:ifs_permits_ids, "{#{ary && ary.join(',')}}")
  end

  def permits_ids
    (
      import_permits_ids +
      export_permits_ids +
      origin_permits_ids +
      ifs_permits_ids
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
    self["#{permit_type}_permit_number"] = permits && permits.map(&:number).join(';')
    # save the array of permit ids in the precomputed field
    send("#{permit_type}_permits_ids=", permits && permits.map(&:id))
  end

  def async_tasks_after_save
    DownloadsCacheCleanupWorker.perform_async('shipments')
    disconnected_permits_ids = @old_permits_ids - permits_ids
    PermitCleanupWorker.perform_async(disconnected_permits_ids)
  end

  def async_tasks_for_destroy
    DownloadsCacheCleanupWorker.perform_async('shipments')
    PermitCleanupWorker.perform_async(@old_permits_ids)
  end
end
