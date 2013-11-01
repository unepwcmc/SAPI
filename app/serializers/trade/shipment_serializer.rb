class Trade::ShipmentSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :quantity, :year,
    :term_id, :unit_id, :purpose_id, :source_id, :taxon_concept_id,
    :importer_id, :exporter_id, :reporter_type, :country_of_origin_id,
    :reported_appendix, :reported_species_name

  has_one :taxon_concept, :serializer => Trade::TaxonConceptSerializer
  has_many :export_permits, :serializer => Trade::PermitSerializer
  has_one :import_permit, :serializer => Trade::PermitSerializer
  has_one :country_of_origin_permit, :serializer => Trade::PermitSerializer
end
