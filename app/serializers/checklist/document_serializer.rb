class Checklist::DocumentSerializer < ActiveModel::Serializer
  attributes :document_type, { date_formatted: :date }, :is_public,
    :primary_document_id, :taxon_names,
    :geo_entity_names, :locale_document,
    :document_language_versions
  include PgArrayParser

  def document_type
    object.document_type.split(":").last
  end

  def document_language_versions
    JSON.parse(object.document_language_versions)
  end

  def locale_document
    doc = document_language_versions.select { |h| h['locale_document'] == 'true' }
    doc = document_language_versions.select { |h| h['locale_document'] == 'default' } if doc.empty?
  end

end
