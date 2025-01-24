# Constructs a normalised hash of parameters, with non-recognised params
# removed.

class Checklist::ChecklistParams < Hash
  include SearchParamSanitiser

  def initialize(original_params)
    get_param =
      Proc.new do |*accessors|
        got = nil

        accessors.each do |accessor|
          if original_params.has_key?(accessor)
            got = original_params[accessor]
            break
          end
        end

        got
      end

    sanitized_params = {
      # possible output layouts are:
      # taxonomic (hierarchic, taxonomic order)
      # alphabetical (flat, alphabetical order)
      output_layout: whitelist_param(
        sanitise_symbol(original_params[:output_layout]),
        [ :taxonomic, :alphabetical, :appendix ],
        :alphabetical
      ),
      level_of_listing: sanitise_boolean(original_params[:level_of_listing], false),
      # filtering options
      scientific_name: sanitise_upcase_string(original_params[:scientific_name]),
      countries: sanitise_integer_array(get_param.(:countries, :country_ids)),
      cites_regions: sanitise_integer_array(get_param.(:cites_regions, :cites_region_ids)),
      cites_appendices: sanitise_string_array(original_params[:cites_appendices]),
      # optional data
      english_common_names: sanitise_boolean(get_param.(:english_common_names, :show_english), false),
      spanish_common_names: sanitise_boolean(get_param.(:spanish_common_names, :show_spanish), false),
      french_common_names: sanitise_boolean(get_param.(:french_common_names, :show_french), false),
      synonyms: sanitise_boolean(get_param.(:synonyms, :show_synonyms), false),
      authors: sanitise_boolean(get_param.(:authors, :show_author), false),
      intro: sanitise_boolean(original_params[:intro], false),
      page: sanitise_positive_integer(original_params[:page], 1),
      per_page: sanitise_positive_integer(original_params[:per_page], 20)
    }

    super(sanitized_params)

    self.merge!(sanitized_params)
  end

  def self.sanitize(original_params)
    new(original_params)
  end
end
