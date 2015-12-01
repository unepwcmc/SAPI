class Species::DocumentsSerializer < ActiveModel::Serializer
  attributes :event_type, :event_name, {date_formatted: :date}, :is_public,
    :document_type, :proposal_number,
    :primary_document_id, :taxon_names, :geo_entity_names,
    :taxon_names, :geo_entity_names, :extension,
    :document_language_versions,
    :proposal_outcome, :review_phase
  include PgArrayParser

  def document_type
    object.document_type.split(":").last
  end

  def taxon_names
    object.taxon_names && parse_pg_array(object.taxon_names) || []
  end

  def geo_entity_names
    object.geo_entity_names && parse_pg_array(object.geo_entity_names) || []
  end

  def document_language_versions
    JSON.parse(object.document_language_versions)
  end

end
