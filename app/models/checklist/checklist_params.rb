# Constructs a normalised list of parameters, with non-recognised params
# removed.
#
# Array parameters are sorted for caching purposes.
class Checklist::ChecklistParams < Hash
  def initialize(params)
    sanitized_params = {
      #possible output layouts are:
      #taxonomic (hierarchic, taxonomic order)
      #alphabetical (flat, alphabetical order)
      :output_layout =>
        params[:output_layout] ? params[:output_layout].to_sym : nil,
      :level_of_listing => params[:level_of_listing] && params[:level_of_listing] != '0',
      #filtering options
      :scientific_name => params[:scientific_name] ? params[:scientific_name] : nil,
      :countries => params[:country_ids] ? params[:country_ids].sort : [],
      :cites_regions =>
        params[:cites_region_ids] ? params[:cites_region_ids].sort : [],
      :cites_appendices =>
        params[:cites_appendices] ? params[:cites_appendices].sort : [],
      # optional data
      :english_common_names => params[:show_english] && params[:show_english] != '0',
      :spanish_common_names => params[:show_spanish] && params[:show_spanish] != '0',
      :french_common_names => params[:show_french] && params[:show_french] != '0',
      :synonyms => params[:show_synonyms] && params[:show_synonyms] != '0',
      :authors => params[:show_author] && params[:show_author] != '0',
      :locale => params[:locale] || 'en', #TODO this is probably redundant
      :page => params[:page] && params[:page].to_i > 0 ? params[:page].to_i : 1,
      :per_page => params[:per_page] && params[:per_page].to_i > 0 ? params[:per_page].to_i : 20
    }
    unless [:taxonomic, :alphabetical, :appendix].include? sanitized_params[:output_layout]
      sanitized_params[:output_layout] = :alphabetical
    end
    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

end