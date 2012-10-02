# == Schema Information
#
# Table name: listing_changes_mview
#
#  id                   :integer          primary key
#  taxon_concept_id     :integer
#  effective_at         :datetime
#  species_listing_id   :integer
#  species_listing_name :string(255)
#  change_type_id       :integer
#  change_type_name     :string(255)
#  party_id             :integer
#  party_name           :string(255)
#  notes                :text
#  dirty                :boolean
#  expiry               :datetime
#

class MListingChange < ListingChange
  self.table_name = :listing_changes_mview
end
