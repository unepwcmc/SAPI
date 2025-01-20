# == Schema Information
#
# Table name: listing_distributions
#
#  id                :integer          not null, primary key
#  is_party          :boolean          default(TRUE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :integer
#  geo_entity_id     :integer          not null
#  listing_change_id :integer          not null
#  original_id       :integer
#  updated_by_id     :integer
#
# Indexes
#
#  idx_on_listing_change_id_geo_entity_id_35e8cc1641  (listing_change_id,geo_entity_id)
#  index_listing_distributions_on_created_by_id       (created_by_id)
#  index_listing_distributions_on_geo_entity_id       (geo_entity_id)
#  index_listing_distributions_on_listing_change_id   (listing_change_id)
#  index_listing_distributions_on_original_id         (original_id)
#  index_listing_distributions_on_updated_by_id       (updated_by_id)
#
# Foreign Keys
#
#  listing_distributions_created_by_id_fk      (created_by_id => users.id)
#  listing_distributions_geo_entity_id_fk      (geo_entity_id => geo_entities.id)
#  listing_distributions_listing_change_id_fk  (listing_change_id => listing_changes.id)
#  listing_distributions_source_id_fk          (original_id => listing_distributions.id)
#  listing_distributions_updated_by_id_fk      (updated_by_id => users.id)
#

class ListingDistribution < ApplicationRecord
  include TrackWhoDoesIt
  # Migrated to controller (Strong Parameters)
  # attr_accessible :geo_entity_id, :listing_change_id, :is_party

  belongs_to :geo_entity
  belongs_to :listing_change, inverse_of: :listing_distributions

  def self.ignored_attributes
    super + [ :source_id ]
  end
end
