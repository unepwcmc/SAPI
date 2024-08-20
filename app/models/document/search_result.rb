##
# This model does not exist on the database - it exists because we serialise
# documents with extra attributes into the cache and then rehydrate them.
#
# This stopped working in the Rails 7 upgrade.
class Document::SearchResult < Document
  serialize :document_language_versions, coder: JSON
  attribute :geo_entity_names, type: String, array: true
  attribute :taxon_names, type: String, array: true
  attribute :document_tags_ids, type: Integer, array: true

  # We need these attributes because we create these objects as
  # Document.from('some_table AS documents'), and some_table may have additional
  # attributes compared to document
  attr_accessor :event_name, :event_type, :date_raw, :designation_name,
    :document_type, :extension, :language, :proposal_number,
    :primary_document_id, :taxon_concept_ids, :proposal_outcome, :review_phase,
    :created_by, :updated_by
end
