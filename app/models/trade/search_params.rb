# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
# Array parameters are sorted for caching purposes.
class Trade::SearchParams < Hash
  def initialize(params)
    sanitized_params = {
      :taxon_concepts_ids =>
        params[:taxon_concepts_ids].blank? ? [] : params[:taxon_concepts_ids].sort,
      :appendices =>
        params[:appendices].blank? ? [] : params[:appendices].sort,
      :time_range_start => params[:time_range_start].to_i,
      :time_range_end => params[:time_range_end].to_i,
      :terms_ids => params[:terms_ids].blank? ? [] : params[:terms_ids].sort,
      :units_ids => params[:units_ids].blank? ? [] : params[:units_ids].sort,
      :purposes_ids =>
        params[:purposes_ids].blank? ? [] : params[:purposes_ids].sort,
      :sources_ids =>
        params[:sources_ids].blank? ? [] : params[:sources_ids].sort,
      :importers_ids =>
        params[:importers_ids].blank? ? [] : params[:importers_ids].sort,
      :exporters_ids =>
        params[:exporters_ids].blank? ? [] : params[:exporters_ids].sort,
      :countries_of_origin_ids=>
        params[:countries_of_origin_ids].blank? ? [] : params[:countries_of_origin_ids].sort,
      :reporter_type => params[:reporter_type].blank? ? nil : params[:reporter_type].upcase,
      :permits_ids => params[:permits_ids].blank? ? [] : params[:permits_ids].sort,
      :quantity => params[:quantity],
      :page => params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1,
      :per_page => params[:per_page] && params[:per_page].to_i > 0 ? params[:per_page].to_i : 25
    }
    unless ['I', 'E'].include? sanitized_params[:reporter_type]
      sanitized_params[:reporter_type] = nil
    end
    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

end
