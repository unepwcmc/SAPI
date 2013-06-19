class Species::SynonymSerializer < ActiveModel::Serializer
  attributes :full_name, :author_year
end
