class Trade::ShipmentFromViewSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :quantity, :year,
    :term_id, :unit_id, :purpose_id, :source_id,
    :taxon_concept_id, :reported_taxon_concept_id,
    :importer_id, :exporter_id, :reporter_type, :country_of_origin_id,
    :import_permit_number, :export_permit_number, :origin_permit_number,
    :legacy_shipment_number, :warnings, :taxon_concept, :reported_taxon_concept

  def taxon_concept
    {
      id: object.taxon_concept_id,
      full_name: object.taxon_concept_full_name + " (#{object.taxon_concept_name_status})",
      author_year: object.taxon_concept_author_year
    }
  end

  def reported_taxon_concept
    {
      id: object.reported_taxon_concept_id,
      full_name: object.reported_taxon_concept_full_name + " (#{object.reported_taxon_concept_name_status})",
      author_year: object.reported_taxon_concept_author_year
    }
  end

end
