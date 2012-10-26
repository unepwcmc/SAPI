class Checklist::Json::History < Checklist::History
  include Checklist::Json::Document
  include Checklist::Json::HistoryContent

  def initialize(options)
    super(options)
    @json_options = json_options
  end

  def json_options
    json_options = super
    #less taxon information for the history
    json_options[:only] -= [:current_listing, :cites_accepted,
      :specific_annotation_symbol, :generic_annotation_symbol
    ]
    json_options[:methods] -= [:recently_changed, :countries_ids,
      :english_names, :spanish_names, :french_names, :synonyms,
      :ancestors_path]
    json_options[:include] = {
      :m_listing_changes => {
        :only => [:change_type_name, :species_listing_name,
          :party_name, :effective_at, :is_current],
        :methods => [:countries_iso_codes] #TODO
      }
    }
    if @locale == 'en'
      json_options[:include][:m_listing_changes][:only] +=
        [:generic_english_full_note, :english_full_note, :english_short_note]
    elsif @locale == 'es'
      json_options[:include][:m_listing_changes][:only] +=
        [:generic_spanish_full_note, :spanish_full_note, :spanish_short_note]
    elsif @locale == 'fr'
      json_options[:include][:m_listing_changes][:only] +=
        [:generic_french_full_note, :french_full_note, :french_short_note]
    end
    json_options
  end

end
