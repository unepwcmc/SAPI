class Species::AcceptedNameSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :author_year, :rank

  def rank
    object.rank.try(:name)
  end
end
