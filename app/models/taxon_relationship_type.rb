# == Schema Information
#
# Table name: taxon_relationship_types
#
#  id                    :integer          not null, primary key
#  name                  :string(255)      not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  is_interdesignational :boolean
#  is_bidirectional      :boolean          default(FALSE)
#

class TaxonRelationshipType < ActiveRecord::Base
  attr_accessible :name, :is_interdesignational, :is_bidirectional

  include Dictionary
  build_dictionary :equal_to, :includes, :overlaps, :disjunct, :has_homonym, :has_synonym

  scope :interdesignational, where(:is_interdesignational => true)
  scope :intradesignational, where(:is_interdesignational => false)
end
