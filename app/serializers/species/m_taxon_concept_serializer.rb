class Species::MTaxonConceptSerializer < ActiveModel::Serializer
  attributes :phylum_name, :order_name, :class_name, :family_name
end

