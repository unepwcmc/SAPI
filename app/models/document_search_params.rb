# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
# Array parameters are sorted for caching purposes.
class DocumentSearchParams < Hash
  def initialize(params)
    sanitized_params = {
      event_id: params['event-id-search'] || params['event_id'],
      event_type: params['event-type-search'],
      document_type: params['document-type'],
      document_title: params['document-title'] ? params['document-title'].strip : nil,
      document_date_start: (Date.parse(params['document-date-start']) rescue nil),
      document_date_end: (Date.parse(params['document-date-end']) rescue nil),
      taxon_concepts_ids: (params['taxon-concepts-ids'].split(',').map(&:to_i) rescue []),
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
