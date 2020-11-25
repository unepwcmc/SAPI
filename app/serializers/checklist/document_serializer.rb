class Checklist::DocumentSerializer < ActiveModel::Serializer
  attributes :document_type, { date_formatted: :date },
    :primary_document_id, :taxon_concept_ids, :taxon_names,
    :geo_entity_names, :locale_document,
    :document_language_versions, :is_public, :is_link
  include PgArrayParser

  def document_type
    object.document_type.split(":").last
  end

  def locale_document
    doc = document_language_versions.select { |h| h['locale_document'] == 'true' }
    doc = document_language_versions.select { |h| h['locale_document'] == 'default' } if doc.empty?
    doc
  end

  def taxon_concept_ids
    object.taxon_concept_ids
  end

  def is_link
    object.document_type == 'Document::VirtualCollege' && !is_pdf?
  end

  def is_pdf?
    (Document.find(object.primary_document_id).elib_legacy_file_name =~ /\.pdf/).present?
  end
end
