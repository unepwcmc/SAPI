class Species::CommonNameSerializer < ActiveModel::Serializer
  attributes :id, :name, :language, :iso_code3

  def language
    object.language.name_en
  end

  def iso_code3
    object.language.iso_code3
  end
end

