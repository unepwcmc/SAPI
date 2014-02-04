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
      :permits_ids => params[:permits_ids].blank? ? [] : params[:permits_ids].sort,
      :reporter_type => params[:reporter_type].blank? ? nil : params[:reporter_type].upcase,
      :time_range_start => params[:time_range_start],
      :time_range_end => params[:time_range_end],
      :quantity => params[:quantity],
      :unit_blank => ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:unit_blank]),
      :purpose_blank => ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:purpose_blank]),
      :source_blank => ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:source_blank]),
      :country_of_origin_blank => ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:country_of_origin_blank]),
      :permit_blank => ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:permit_blank]),
      :internal => ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:internal]),
      :report_type => params[:report_type] ? params[:report_type].to_sym : :raw,
      :page => params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1,
      :per_page => params[:per_page] && params[:per_page].to_i > 0 ? params[:per_page].to_i : 100
    }
    unless ['I', 'E'].include? sanitized_params[:reporter_type]
      sanitized_params[:reporter_type] = nil
    end
    # make sure quantity is numeric
    begin
      sanitized_params[:quantity] = Float(sanitized_params[:quantity])
    rescue ArgumentError, TypeError
      sanitized_params[:quantity] = nil
    end
    [:time_range_start, :time_range_end].each do |integer_param|
      # make sure is integer
      begin
        sanitized_params[:integer_param] = Integer(sanitized_params[:integer_param])
      rescue ArgumentError, TypeError
        sanitized_params[:integer_param] = nil
      end
    end
    [
      :taxon_concepts_ids, :terms_ids, :units_ids, :purposes_ids,
      :sources_ids, :importers_ids, :exporters_ids, :countries_of_origin_ids,
      :permits_ids
    ].each do |integer_array_param|
      # make sure is array
      sanitized_params[integer_array_param] = [] unless sanitized_params[integer_array_param].is_a?(Array)
      # make sure elements are integers
      begin
        !sanitized_params[integer_array_param].empty? && Integer(sanitized_params[integer_array_param][0])
      rescue ArgumentError, TypeError
        sanitized_params[integer_array_param] = []
      end
    end
    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

end
