# == Schema Information
#
# Table name: geo_entity_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GeoEntityType < ActiveRecord::Base
  attr_accessible :name

  include Dictionary
  build_dictionary :country, :cites_region, :region, :territory,
    :aquatic_territory, :bru, :trade_entity

  SETS = {
    "1" => [CITES_REGION],
    "2" => [COUNTRY, TERRITORY],
    "3" => [CITES_REGION, COUNTRY, TERRITORY],
    "4" => [COUNTRY, TERRITORY, TRADE_ENTITY]
  }
end
