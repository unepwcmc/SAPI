class Trade::SandboxShipmentSerializer < ActiveModel::Serializer
  attributes :id, :appendix, :species_name, :term_code,
    :quantity, :unit_code, :trading_partner, :country_of_origin,
    :export_permit, :origin_permit, :purpose_code, :source_code,
    :year, :import_permit
end
