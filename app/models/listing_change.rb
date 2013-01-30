# == Schema Information
#
# Table name: listing_changes
#
#  id                         :integer          not null, primary key
#  taxon_concept_id           :integer          not null
#  species_listing_id         :integer
#  change_type_id             :integer          not null
#  effective_at               :datetime         default(2012-09-21 07:32:20 UTC), not null
#  is_current                 :boolean          default(FALSE), not null
#  annotation_id              :integer
#  parent_id                  :integer
#  inclusion_taxon_concept_id :integer
#  lft                        :integer
#  rgt                        :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  import_row_id              :integer
#

class ListingChange < ActiveRecord::Base

  attr_accessible :taxon_concept_id, :species_listing_id, :change_type_id,
    :effective_at, :parent_id

  belongs_to :species_listing
  belongs_to :taxon_concept
  belongs_to :change_type
  has_many :listing_distributions
  has_many :geo_entities, :through => :listing_distributions
  belongs_to :annotation
  belongs_to :parent, :class_name => 'ListingChange'
  validates :change_type_id, :presence => true
end
