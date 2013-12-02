class Trade::ShipmentSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :quantity, :year,
    :term_id, :unit_id, :purpose_id, :source_id, :taxon_concept_id,
    :importer_id, :exporter_id, :reporter_type, :country_of_origin_id,
    :import_permit_number, :export_permit_number, :country_of_origin_permit_number,
    :warnings

  has_one :taxon_concept, :serializer => Trade::TaxonConceptSerializer
end
