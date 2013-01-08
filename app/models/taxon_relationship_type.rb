# == Schema Information
#
# Table name: taxon_relationship_types
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_inter_designational :boolean
#

class TaxonRelationshipType < ActiveRecord::Base
  attr_accessible :name, :is_inter_designational

  include Dictionary
  build_dictionary :equal_to, :includes, :included_in, :overlaps, :disjunct, :has_homonym, :has_synonym

  def inter_designational
    where(:is_inter_designational => true)
  end
  def intra_designational
    where(:is_inter_designational => false)
  end
end
