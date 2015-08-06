class Species::DocumentsSerializer < ActiveModel::Serializer
  attributes :id, :event_type, :event_name, :event_date, :title, :is_public,
    :document_type, :number, :sort_index, :language, :proposal_outcome,
    :primary_document_id, :taxon_concept_ids, :geo_entity_ids

  def event_date
    DateTime.parse(object.event_date).strftime("%d-%m-%Y")
  end

  def document_type
    object.document_type.split(":").last
  end
end
