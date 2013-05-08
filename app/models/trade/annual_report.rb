class Trade::AnnualReport < ActiveRecord::Base
  attr_accessible :geo_entity_id, :year
  belongs_to :geo_entity
end
