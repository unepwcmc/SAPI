class Trade::TaxonConceptCodePair < ActiveRecord::Base
  attr_accessible :taxon_concept_id, :trade_code_id, :trade_code_type
end
