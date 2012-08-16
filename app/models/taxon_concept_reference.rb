# == Schema Information
#
# Table name: taxon_concept_references
#
#  id               :integer          not null, primary key
#  taxon_concept_id :integer          not null
#  reference_id     :integer          not null
#  data             :hstore           not null
#

class TaxonConceptReference < ActiveRecord::Base
  attr_accessible :reference_id, :taxon_concept_id, :data
  serialize :data, ActiveRecord::Coders::Hstore
  belongs_to :reference
  belongs_to :taxon_concept
end
