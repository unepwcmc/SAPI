class Trade::TaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :author_year, :rank_name

  def full_name
    object.full_name + " (#{object.name_status})"
  end
end
