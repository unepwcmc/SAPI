class Species::ExportsController < ApplicationController
  include SearchParamSanitiser

  before_action :ensure_data_type_and_filters, only: [ :download ]

  def download
    set_csv_separator

    @filters = filter_params.merge(
      {
        csv_separator: cookies['speciesplus.csv_separator'].try(:to_sym)
      }
    )
    case params[:data_type]
    when 'Quotas'
      result = Quota.export @filters
    when 'CitesSuspensions'
      result = CitesSuspension.export @filters
    when 'Listings'
      result = Species::ListingsExportFactory.new(@filters).export
    when 'EuDecisions'
      result = Species::EuDecisionsExport.new(@filters).export
    when 'Processes'
      result = Species::CitesProcessesExport.new(@filters).export
    end
    respond_to do |format|
      format.html do
        if result.is_a?(Array)
          # this was added in order to prevent download managers from
          # failing when chunked_transfer_encoding is set in nginx (1.8.1)
          file_path = Pathname.new(result[0]).realpath
          response.headers['Content-Length'] = File.size(file_path).to_s
          send_file file_path, result[1]
        else
          redirect_to species_exports_path, notice: "There are no #{params[:data_type]} to download."
        end
      end
      format.json do
        render json: { total: result.is_a?(Array) ? 1 : 0 }
      end
    end
  end

private

  def filter_params
    normalize_export_filters(params[:filters].permit!.to_h)
  rescue NoMethodError
    {}.with_indifferent_access
  end

  # Export endpoints still fan out into legacy code that mixes symbol and
  # string lookups on the same filters hash. Normalising once here keeps the
  # request shape stable for every export and prevents array-overlap queries
  # from receiving string IDs straight from params. We only normalise keys that
  # the request actually sent, because legacy filters use `key?` to decide
  # whether a WHERE clause should be applied.
  def normalize_export_filters(raw_filters)
    normalized_filters = raw_filters.with_indifferent_access

    normalize_array_filter!(normalized_filters, raw_filters, :taxon_concepts_ids)
    normalize_array_filter!(normalized_filters, raw_filters, :geo_entities_ids)
    normalize_array_filter!(normalized_filters, raw_filters, :years)
    normalize_array_filter!(normalized_filters, raw_filters, :species_listings_ids)
    normalize_integer_filter!(normalized_filters, raw_filters, :designation_id)

    normalized_filters
  end

  # These helpers intentionally mutate `normalized_filters` in place so the
  # caller can preserve the original key-presence semantics while replacing
  # only the submitted values with sanitised equivalents.
  def normalize_array_filter!(normalized_filters, raw_filters, key)
    return unless raw_filters.key?(key) || raw_filters.key?(key.to_s)

    normalized_filters[key] = sanitise_integer_array(raw_filters[key] || raw_filters[key.to_s])
  end

  def normalize_integer_filter!(normalized_filters, raw_filters, key)
    return unless raw_filters.key?(key) || raw_filters.key?(key.to_s)

    normalized_filters[key] = sanitise_positive_integer(raw_filters[key] || raw_filters[key.to_s])
  end

  def set_csv_separator
    separator_params = params[:filters][:csv_separator]
    separator_cookie = cookies['speciesplus.csv_separator']
    if separator_params.present?
      cookies.permanent['speciesplus.csv_separator'] = separator_params
    elsif separator_cookie.present?
      nil
    else
      ip = request.remote_ip
      separator = SapiModule::GeoIP.instance.default_separator(ip)
      cookies.permanent['speciesplus.csv_separator'] = separator
    end
  end

  def ensure_data_type_and_filters
    unless params[:data_type] && params[:filters]
      head :unprocessable_entity
      false
    end
  end
end
