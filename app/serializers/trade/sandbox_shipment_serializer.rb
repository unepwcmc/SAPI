class Trade::SandboxShipmentSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :taxon_name, :accepted_taxon_name,
    :term_code, :quantity, :unit_code, :trading_partner, :country_of_origin,
    :export_permit, :origin_permit, :purpose_code, :source_code,
    :year, :import_permit
  def accepted_taxon_name
    object.taxon_concept && object.taxon_concept.full_name
  end
end
