class Species::TaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :author_year, :rank_name,
    :family_id, :family_name, :order_id, :order_name,
    :phylum_id, :phylum_name, :class_id, :class_name,
    :parent_id, :taxonomic_position, :synonyms, :matching_names

  delegate :params, to: :scope

  def matching_names
    names = (object.synonyms + object.english_names +
      object.french_names + object.spanish_names).sort
    if params[:taxon_concept_query].present?
      names.select do |a|
        a.downcase.include?(params[:taxon_concept_query].downcase)
      end
    else
      names
    end
  end
end
