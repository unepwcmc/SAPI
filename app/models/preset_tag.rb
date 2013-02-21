class PresetTag < ActiveRecord::Base
  attr_accessible :model, :name

  TYPES = {
    :TaxonConcept => 'TaxonConcept',
    :Distribution => 'Distribution'
  }

  validates :name, :presence => true
  validates :model, :inclusion => { :in => TYPES.values }
end
