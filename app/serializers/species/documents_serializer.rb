class Species::DocumentsSerializer < ActiveModel::Serializer
  attributes :id, :event_type, :event_name, :event_date, :title, :is_public

  def event_date
    DateTime.parse(object.event_date).strftime("%d-%m-%Y")
  end
end
