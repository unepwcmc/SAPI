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
      :level_of_listing => params[:level_of_listing] == '1',
      #filtering options
      :scientific_name => params[:scientific_name] ? params[:scientific_name] : nil,
      :countries => params[:country_ids] ? params[:country_ids].sort : [],
      :cites_regions =>
        params[:cites_region_ids] ? params[:cites_region_ids].sort : [],
      :cites_appendices =>
        params[:cites_appendices] ? params[:cites_appendices].sort : [],
      # optional data
      :english_common_names => params[:show_english] == '1',
      :spanish_common_names => params[:show_spanish] == '1',
      :french_common_names => params[:show_french] == '1',
      :synonyms => params[:show_synonyms] == '1',
      :authors => params[:show_author] == '1',
      :locale => params[:locale] || 'en' #TODO this is probably redundant
    }
    super(sanitized_params)
    self.merge!(sanitized_params)
  end
end