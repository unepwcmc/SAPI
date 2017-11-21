class Species::AutocompleteTaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :rank_name, :name_status, :matching_names

  def rank_name
    rank_with_locale = "rank_display_name_#{I18n.locale.to_s}"
    object.send(rank_with_locale.to_sym)
  end
end
