# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
class Checklist::ChecklistParams < Hash
  include SearchParamSanitiser

  def initialize(params)
    sanitized_params = {
      # possible output layouts are:
      # taxonomic (hierarchic, taxonomic order)
      # alphabetical (flat, alphabetical order)
      output_layout: whitelist_param(
        sanitise_symbol(params[:output_layout]),
        [:taxonomic, :alphabetical, :appendix],
        :alphabetical
      ),
      level_of_listing: sanitise_boolean(params[:level_of_listing], false),
      # filtering options
      scientific_name: sanitise_upcase_string(params[:scientific_name]),
      countries: sanitise_integer_array(params[:country_ids]),
      cites_regions: sanitise_integer_array(params[:cites_region_ids]),
      cites_appendices: sanitise_string_array(params[:cites_appendices]),
      # optional data
      english_common_names: sanitise_boolean(params[:show_english], false),
      spanish_common_names: sanitise_boolean(params[:show_spanish], false),
      french_common_names: sanitise_boolean(params[:show_french], false),
      synonyms: sanitise_boolean(params[:show_synonyms], false),
      authors: sanitise_boolean(params[:show_author], false),
      intro: sanitise_boolean(params[:intro], false),
      page: sanitise_positive_integer(params[:page], 1),
      per_page: sanitise_positive_integer(params[:per_page], 20)
    }

    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

end
