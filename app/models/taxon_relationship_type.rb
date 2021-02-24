# == Schema Information
#
# Table name: taxon_relationship_types
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  is_intertaxonomic :boolean          default(FALSE), not null
#  is_bidirectional  :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class TaxonRelationshipType < ActiveRecord::Base
  attr_accessible :name, :is_intertaxonomic, :is_bidirectional

  include Dictionary
  build_dictionary :equal_to, :includes, :overlaps, :disjunct, :has_synonym,
    :has_hybrid, :has_trade_name

  scope :intertaxonomic, -> { where(:is_intertaxonomic => true) }
  scope :intrataxonomic, -> { where(:is_intertaxonomic => false) }
end
