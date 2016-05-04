class Species::EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :type

  def name
    name = object.name
    "#{name} #{object.effective_at.strftime('(%B %Y)')}" if object.effective_at
  end
end
