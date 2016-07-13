class Checklist::AutocompleteTaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :rank_name, :matching_names

  def rank_name
    object.rank_display_name
  end
end
