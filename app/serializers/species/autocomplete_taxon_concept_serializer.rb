class Species::AutocompleteTaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :rank_name, :other_search_matches

  def other_search_matches
    (object.synonyms + object.english_names +
      object.french_names + object.spanish_names).sort
  end
end
