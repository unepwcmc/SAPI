# == Schema Information
#
# Table name: listing_distributions
#
#  id                :integer         not null, primary key
#  listing_change_id :integer
#  geo_entity_id     :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

class ListingDistribution < ActiveRecord::Base
  attr_accessible :geo_entity_id, :listing_change_id, :is_party
  belongs_to :geo_entity
  belongs_to :listing_change
end
