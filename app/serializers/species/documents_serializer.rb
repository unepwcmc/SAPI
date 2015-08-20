class Species::DocumentsSerializer < ActiveModel::Serializer
  attributes :id, :event_type, :event_name, :date, :title, :is_public,
    :document_type, :number, :sort_index, :language,
    :primary_document_id, :taxon_names, :geo_entity_names,
    :taxon_names, :geo_entity_names, :languages, :extension

  def document_type
    object.document_type.split(":").last
  end

  def taxon_names
    object.taxon_names.split(',')
  end

  def geo_entity_names
    object.geo_entity_names.split(',')
  end

  def title
    JSON.parse(object.document_language_versions).first["title"]
  end

  def language
    JSON.parse(object.document_language_versions).first["language"]
  end

  def languages
    "Languages"
  end

end
