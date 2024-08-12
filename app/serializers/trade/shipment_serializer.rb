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
#  index_trade_shipments_on_created_by_id_and_updated_by_id  (created_by_id,updated_by_id)
#  index_trade_shipments_on_export_permits_ids               (export_permits_ids) USING gin
#  index_trade_shipments_on_exporter_id                      (exporter_id)
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
#  index_trade_shipments_on_unit_id                          (unit_id)
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
class Trade::ShipmentSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :quantity, :year,
    :term_id, :unit_id, :purpose_id, :source_id,
    :taxon_concept_id, :reported_taxon_concept_id,
    :importer_id, :exporter_id, :reporter_type, :country_of_origin_id,
    :import_permit_number, :export_permit_number, :origin_permit_number,
    :legacy_shipment_number, :warnings

  has_one :taxon_concept, serializer: Trade::TaxonConceptSerializer
  has_one :reported_taxon_concept, serializer: Trade::TaxonConceptSerializer
end
