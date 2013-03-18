# == Schema Information
#
# Table name: taxon_concept_references
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer          not null
#  reference_id     :integer          not null
#  data             :hstore
#

class TaxonConceptReference < ActiveRecord::Base
  attr_accessible :reference_id, :taxon_concept_id, :data, :reference_attributes

  serialize :data, ActiveRecord::Coders::Hstore

  belongs_to :reference
  belongs_to :taxon_concept

  accepts_nested_attributes_for :reference

  validates :reference_id, :uniqueness => { :scope => [:taxon_concept_id] }
end
