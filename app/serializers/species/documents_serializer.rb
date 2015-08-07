class Species::DocumentsSerializer < ActiveModel::Serializer
  attributes :id, :event_type, :event_name, :event_date, :title, :is_public,
    :document_type, :number, :sort_index, :language, :proposal_outcome,
    :primary_document_id, :taxon_concept_ids, :geo_entity_ids,
    :taxon_names, :geo_entity_names, :languages

  def document_type
    object.document_type.split(":").last
  end

  def languages
    "Languages"
  end

end
