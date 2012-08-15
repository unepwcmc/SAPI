class StandardReference < ActiveRecord::Base
  attr_accessible :author, :reference_id, :reference_legacy_id,
  :species_legacy_id, :taxon_concept_id, :taxon_concept_name,
  :taxon_concept_rank, :title, :year
end
