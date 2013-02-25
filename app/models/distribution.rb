# == Schema Information
#
# Table name: distributions
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer          not null
#  geo_entity_id    :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Distribution < ActiveRecord::Base
  attr_accessible :geo_entity_id, :taxon_concept_id, :tag_list, :references_attributes
  acts_as_taggable

  belongs_to :geo_entity
  belongs_to :taxon_concept

  has_and_belongs_to_many :references, :join_table => :distribution_references
  accepts_nested_attributes_for :references, :allow_destroy => true

  validates :taxon_concept_id, :uniqueness => { :scope => :geo_entity_id }
end
