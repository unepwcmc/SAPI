# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
class DocumentSearchParams < Hash
  include SearchParamSanitiser

  def initialize(params)
    sanitized_params = {
      events_ids: sanitise_integer_array(params['events_ids']),
      event_type: sanitise_string(params['event_type']),
      document_type: sanitise_string(params['document_type']),
      title_query: sanitise_string(params['title_query']),
      language: sanitise_string(params['locale']),
      volume: sanitise_integer_array(params['volume']),
      document_date_start: (Date.parse(params['document_date_start']) rescue nil),
      document_date_end: (Date.parse(params['document_date_end']) rescue nil),
      taxon_concepts_ids: sanitise_doc_ids_array(params['taxon_concepts_ids']),
      geo_entities_ids: sanitise_integer_array(params['geo_entities_ids']),
      document_tags_ids: sanitise_integer_array(params['document_tags_ids']) + [
        sanitise_positive_integer(params['proposal_outcome_id']),
        sanitise_positive_integer(params['review_phase_id'])
      ].compact,
      general_subtype: params['general_subtype'],
      show_private: sanitise_boolean(params[:show_private], false),
      page: sanitise_positive_integer(params[:page], 1),
      per_page: sanitise_positive_integer(params[:per_page], 25)
    }
    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

end
