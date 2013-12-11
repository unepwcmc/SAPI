class Species::AutocompleteTaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :rank_name, :matching_names

  def matching_names
    (object.synonyms + object.english_names +
      object.french_names + object.spanish_names).sort
  end
end
