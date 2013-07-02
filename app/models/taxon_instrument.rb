class TaxonInstrument < ActiveRecord::Base
  attr_accessible :effective_from, :instrument_id, :taxon_concept_id
end
