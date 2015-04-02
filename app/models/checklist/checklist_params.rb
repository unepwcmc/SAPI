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
      :scientific_name => params[:scientific_name] ? params[:scientific_name].upcase : nil,
      :countries => if params[:country_ids].present? && params[:country_ids].is_a?(Array)
        params[:country_ids].sort
      else
        []
      end,
      :cites_regions => if params[:cites_region_ids].present? && params[:cites_region_ids].is_a?(Array)
        params[:cites_region_ids].sort
      else
        []
      end,
      :cites_appendices => if params[:cites_appendices].present?  && params[:cites_appendices].is_a?(Array)
        params[:cites_appendices].sort
      else
        []
      end,
      # optional data
      :english_common_names => params[:show_english] && params[:show_english] != '0',
      :spanish_common_names => params[:show_spanish] && params[:show_spanish] != '0',
      :french_common_names => params[:show_french] && params[:show_french] != '0',
      :synonyms => params[:show_synonyms] && params[:show_synonyms] != '0',
      :authors => params[:show_author] && params[:show_author] != '0',
      :intro => ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:intro]),
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