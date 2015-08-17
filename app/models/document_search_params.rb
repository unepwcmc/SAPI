# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
# Array parameters are sorted for caching purposes.
class DocumentSearchParams < Hash
  def initialize(params)
    sanitized_params = {
      event_id: params['event_id_search'] || params['event_id'],
      event_type: params['event_type_search'],
      document_type: params['document_type'],
      document_title: params['document_title'] ? params['document_title'].strip : nil,
      document_date_start: (Date.parse(params['document_date_start']) rescue nil),
      document_date_end: (Date.parse(params['document_date_end']) rescue nil),
      taxon_concepts_ids: (params['taxon_concepts_ids'].split(',').map(&:to_i) rescue []),
      geo_entities_ids: (params['geo_entities_ids'].map(&:to_i) rescue []),
      proposal_outcome_ids: (params['proposal_outcome_ids'].split(',').map(&:to_i) rescue []),
      review_phase_ids: (params['review_phase_ids'].split(',').map(&:to_i) rescue []),
      document_tags_ids: (params['document_tags_ids'].map(&:to_i) rescue []),
      page: params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1,
      per_page: params[:per_page] && params[:per_page].to_i > 0 ? params[:per_page].to_i : 25
    }
    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

end
