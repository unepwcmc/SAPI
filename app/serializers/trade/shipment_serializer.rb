class Trade::ShipmentSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :reported_appendix, :term_code,
    :quantity, :unit_code, :trading_partner, :country_of_origin,
    :import_permit, :export_permit, :purpose_code, :source_code,
    :year, :species_name, :origin_permit

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

  def country_of_origin
    object.country_of_origin.try(:name_en)
  end

  def trading_partner
    if object.reported_by_exporter?
      object.importer.try(:name_en)
    else
      object.exporter.try(:name_en)
    end
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
