class Checklist::TimelinesForTaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :taxon_concept_id
  has_many :timeline_years, :timelines
end
