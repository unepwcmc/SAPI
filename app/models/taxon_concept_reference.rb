class TaxonConceptReference < ActiveRecord::Base
  attr_accessible :reference_id, :taxon_concept_id, :data
  serialize :data, ActiveRecord::Coders::Hstore
  belongs_to :reference
  belongs_to :taxon_concept
end
