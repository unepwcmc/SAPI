# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
class Trade::SearchParams < Hash
  include SearchParamSanitiser

  def initialize(params)
    sanitized_params = {
      taxon_concepts_ids: sanitise_integer_array(params[:taxon_concepts_ids]),
      reported_taxon_concepts_ids: sanitise_integer_array(params[:reported_taxon_concepts_ids]),
      appendices: sanitise_string_array(params[:appendices]),
      terms_ids: sanitise_integer_array(params[:terms_ids]),
      units_ids: sanitise_integer_array(params[:units_ids]),
      purposes_ids: sanitise_integer_array(params[:purposes_ids]),
      sources_ids: sanitise_integer_array(params[:sources_ids]),
      importers_ids: sanitise_integer_array(params[:importers_ids]),
      exporters_ids: sanitise_integer_array(params[:exporters_ids]),
      countries_of_origin_ids: sanitise_integer_array(params[:countries_of_origin_ids]),
      permits_ids: sanitise_integer_array(params[:permits_ids]),
      reporter_type: whitelist_param(
        sanitise_upcase_string(params[:reporter_type]),
        ['I', 'E'],
        nil
      ),
      time_range_start: sanitise_positive_integer(params[:time_range_start], 1975),
      time_range_end: sanitise_positive_integer(params[:time_range_end], Date.today.year),
      quantity: sanitise_float(params[:quantity]),
      unit_blank: sanitise_boolean(params[:unit_blank]),
      purpose_blank: sanitise_boolean(params[:purpose_blank]),
      source_blank: sanitise_boolean(params[:source_blank]),
      country_of_origin_blank: sanitise_boolean(params[:country_of_origin_blank]),
      permit_blank: sanitise_boolean(params[:permit_blank]),
      internal: sanitise_boolean(params[:internal]),
      report_type: sanitise_symbol(params[:report_type], :raw),
      taxon_with_descendants: sanitise_boolean(params[:taxon_with_descendants]),
      shipments_view: sanitise_compliance_type(params[:compliance_type]),
      page: sanitise_positive_integer(params[:page], 1),
      per_page: sanitise_positive_integer(params[:per_page], 100)
    }

    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

  private

  COMPLIANCE_TYPES_VIEWS = {
    appendix_i: "trade_shipments_appendix_i_mview",
    trade_suspensions: "trade_shipments_cites_suspensions_mview",
    mandatory_quotas: "trade_shipments_mandatory_quotas_mview"
  }
  def sanitise_compliance_type(compliance_type)
    compliance_type.present? ? COMPLIANCE_TYPES_VIEWS[compliance_type.to_sym] : "trade_shipments_with_taxa_view"
  end

end
