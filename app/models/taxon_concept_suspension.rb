class TaxonConceptSuspension < ActiveRecord::Base
  attr_accessible :suspension_id, :taxon_concept_id, :suspension_attributes

  belongs_to :suspension, :dependent => :destroy
  belongs_to :taxon_concept

  accepts_nested_attributes_for :suspension

  validates :suspension_id, :uniqueness => true
end
