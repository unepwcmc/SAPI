class Species::DocumentSerializer < ActiveModel::Serializer
  attributes :event_type, :event_name, {date_formatted: :date}, :is_public,
    :document_type, :proposal_number,
    :primary_document_id, :taxon_names, :geo_entity_names,
    :taxon_names, :geo_entity_names,
    :document_language_versions,
    :proposal_outcome, :review_phase
  include PgArrayParser

  def document_type
    object.document_type.split(":").last
  end

  def document_language_versions
    JSON.parse(object.document_language_versions)
  end

end
