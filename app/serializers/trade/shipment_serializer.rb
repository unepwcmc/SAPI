class Trade::ShipmentSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :reported_appendix, :species_name,
    :term_code, :quantity, :unit_code, :purpose_code, :source_code, :year,
    :importer, :exporter, :reporter_type, :country_of_origin,
    :import_permit, :export_permit, :origin_permit

  def species_name
    object.taxon_concept.full_name
  end

  def source_code
    object.source.try(:code)
  end

  def term_code
    object.term.try(:code)
  end

  def unit_code
    object.unit.try(:code)
  end

  def purpose_code
    object.purpose.try(:code)
  end

  def importer
    object.importer.try(:name_en)
  end

  def exporter
    object.exporter.try(:name_en)
  end

  def country_of_origin
    object.country_of_origin.try(:name_en)
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
