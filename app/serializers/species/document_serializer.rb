class Species::DocumentSerializer < ActiveModel::Serializer
  attributes :event_type, :event_name, { date_formatted: :date }, :is_public,
    :document_type, :proposal_number,
    :primary_document_id, :taxon_names, :geo_entity_names,
    :taxon_names, :geo_entity_names,
    :document_language_versions,
    :proposal_outcome, :is_link

  def document_type
    object.document_type.split(":").last
  end

  def document_language_versions
    object.document_language_versions
  end

  def is_link
    object.document_type == 'Document::VirtualCollege' && !is_pdf?
  end

  def is_pdf?
    (Document.find(object.primary_document_id).elib_legacy_file_name =~ /\.pdf/).present?
  end
end
