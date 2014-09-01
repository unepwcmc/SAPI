class Species::AutocompleteTaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :rank_name, :name_status, :matching_names
end
