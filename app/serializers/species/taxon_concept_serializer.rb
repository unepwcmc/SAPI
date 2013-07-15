class Species::TaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :author_year, :rank_name,
    :family_id, :family_name, :order_id, :order_name,
    :phylum_id, :phylum_name, :class_id, :class_name,
    :parent_id, :taxonomic_position
end
