class Trade::SandboxShipmentSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :taxon_name, :reported_taxon_name, :accepted_taxon_name,
    :term_code, :quantity, :unit_code,
    :trading_partner, :country_of_origin,
    :export_permit, :origin_permit, :import_permit, :ifs_permit,
    :purpose_code, :source_code,
    :year

  def reported_taxon_name
    (object.reported_taxon_concept && "#{object.reported_taxon_concept.full_name} (#{object.reported_taxon_concept.name_status})") ||
    object.taxon_name
  end

  def accepted_taxon_name
    object.taxon_concept && "#{object.taxon_concept.full_name} (#{object.taxon_concept.name_status})"
  end
end
