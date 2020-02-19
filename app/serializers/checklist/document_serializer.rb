class Checklist::DocumentSerializer < ActiveModel::Serializer
  attributes :document_type, { date_formatted: :date },
    :primary_document_id, :taxon_concept_ids, :taxon_names,
    :geo_entity_names, :locale_document,
    :document_language_versions, :is_public
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
    doc
  end

  def taxon_concept_ids
    object.taxon_names.map { |tn| MTaxonConcept.find_by_full_name(tn).id }
  end
end
