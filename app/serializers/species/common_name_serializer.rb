class Species::CommonNameSerializer < ActiveModel::Serializer
  attributes :name
  has_one :language, :serializer => Species::LanguageSerializer
end
