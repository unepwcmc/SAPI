# == Schema Information
#
# Table name: listing_distributions
#
#  id                :integer          not null, primary key
#  listing_change_id :integer          not null
#  geo_entity_id     :integer          not null
#  is_party          :boolean          default(TRUE), not null
#  original_id       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :integer
#  updated_by_id     :integer
#

class ListingDistribution < ApplicationRecord
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :geo_entity_id, :listing_change_id, :is_party

  belongs_to :geo_entity
  belongs_to :listing_change, :inverse_of => :listing_distributions

  def self.ignored_attributes
    super() + [:source_id]
  end
end
