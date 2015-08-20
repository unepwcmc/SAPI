class Species::DocumentsSerializer < ActiveModel::Serializer
  attributes :event_type, :event_name, :date, :is_public,
    :document_type, :number,
    :primary_document_id, :taxon_names, :geo_entity_names,
    :taxon_names, :geo_entity_names, :extension,
    :document_language_versions
  include PgArrayParser

  def document_type
    object.document_type.split(":").last
  end

  def taxon_names
    parse_pg_array(object.taxon_names)
  end

  def geo_entity_names
    parse_pg_array(object.geo_entity_names)
  end

  def document_language_versions
    JSON.parse(object.document_language_versions)
  end

end
