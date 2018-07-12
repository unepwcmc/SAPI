class Trade::ShipmentApiFromViewSerializer < ActiveModel::Serializer
   attributes :id , :year, :appendix, :taxon, :class, :order, :family, :genus,
              :term, :importer_reported_quantity, :exporter_reported_quantity,
              :unit, :importer, :exporter, :origin, :purpose, :source,
              :compliance_type_taxonomic_rank,
              :import_permit,
              :export_permit, :origin_permit

  def importer_reported_quantity
    object.attributes['importer_reported_quantity'] || object.attributes['importer_quantity']
  end

  def exporter_reported_quantity
    object.attributes['exporter_reported_quantity'] || object.attributes['exporter_quantity']
  end

end
