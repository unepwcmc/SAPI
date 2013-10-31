class Trade::ShipmentSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :species_name,
    :term_id, :quantity, :unit_id, :purpose_id, :source_id, :year,
    :importer_id, :exporter_id, :reporter_type, :country_of_origin_id,
    :import_permit, :export_permit, :origin_permit,
    :reported_appendix, :reported_species_name

  def species_name
    object.taxon_concept.full_name
  end

  def export_permit
    object.export_permit.try(:number)
  end

  def import_permit
    object.import_permit.try(:number)
  end

  def origin_permit
    object.country_of_origin_permit.try(:number)
  end

  def country_of_origin_permit
    object.country_of_origin_permit.try(:number)
  end
end
