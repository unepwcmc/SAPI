class TaxonConceptSuspension < ActiveRecord::Base
  attr_accessible :suspension_id, :taxon_concept_id, :suspension_attributes

  belongs_to :suspension
  belongs_to :taxon_concept
end
