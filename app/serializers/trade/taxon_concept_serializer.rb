class Trade::TaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :author_year, :rank_name
end
