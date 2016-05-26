class Species::EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :type

  def name
    name = object.name
    "#{name} #{object.published_at.strftime('(%B %Y)')}" if object.published_at
  end
end
