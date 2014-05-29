class NomenclatureChangeComponent < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :is_input, :is_output,
    :nomenclature_change_id, :taxon_concept_id, :updated_by_id
  validates_presence_of :taxon_concept_id
end
