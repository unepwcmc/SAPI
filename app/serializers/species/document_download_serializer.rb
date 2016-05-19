class Species::DocumentDownloadSerializer < ActiveModel::Serializer
  attributes :id, :event_type, :event_name, :document_type

  def event_type
    Event.find(object.event_id).type
  end

  def event_name
    Event.find(object.event_id).name
  end

  def document_type
    Document.find(object.id).type.split("::").last
  end

end
