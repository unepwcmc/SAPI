# == Schema Information
#
# Table name: listing_changes
#
#  id                 :integer         not null, primary key
#  species_listing_id :integer
#  taxon_concept_id   :integer
#  change_type_id     :integer
#  reference_id       :integer
#  lft                :integer
#  rgt                :integer
#  parent_id          :integer
#  depth              :integer
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  effective_at       :datetime        default(2012-06-26 10:13:03 UTC), not null
#

class ListingChange < ActiveRecord::Base

  attr_accessible :taxon_concept_id, :species_listing_id, :change_type_id, :effective_at

  belongs_to :species_listing
  belongs_to :taxon_concept
  belongs_to :change_type
end
