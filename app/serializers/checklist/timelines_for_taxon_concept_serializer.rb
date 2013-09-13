class Checklist::TimelinesForTaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :taxon_concept_id, :has_descendant_timelines, :has_events
  has_many :timeline_years, :timelines
end
