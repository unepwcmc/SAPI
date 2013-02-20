class PresetTag < ActiveRecord::Base
  attr_accessible :model, :name

  TYPES = {
    :TaxonConcept => 'TaxonConcept',
    :Distribution => 'Distribution'
  }
end
