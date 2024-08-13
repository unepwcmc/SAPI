# == Schema Information
#
# Table name: geo_entity_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GeoEntityType < ApplicationRecord
  # Look like the only place create GeoEntityType is lib/tasks/import_trade_shipments.rake
  # attr_accessible :name

  include Dictionary
  build_dictionary :country, :cites_region, :region, :territory,
    :aquatic_territory, :bru, :trade_entity

  DEFAULT_SET = '3'
  SETS = {
    '1' => [CITES_REGION], # CITES Checklist
    '2' => [COUNTRY, REGION, TERRITORY], # CITES Checklist
    '3' => [CITES_REGION, COUNTRY, TERRITORY], # Species+
    '4' => [COUNTRY, REGION, TERRITORY, TRADE_ENTITY], # CITES Trade
    '5' => [COUNTRY, TERRITORY] # E-library
  }
  CURRENT_ONLY_SETS = ['3']
end
