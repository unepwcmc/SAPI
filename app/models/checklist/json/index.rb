class Checklist::Json::Index < Checklist::Index
  include Checklist::Json::Document
  include Checklist::Json::IndexContent

  def initialize(options)
    super(options.merge({:output_layout => :taxonomic}))
  end

  def sql_columns
    sql_columns = super()
    if @locale == 'en'
      sql_columns +=
        [:generic_english_full_note, :english_full_note]
    elsif @locale == 'es'
      sql_columns +=
        [:generic_spanish_full_note, :spanish_full_note]
    elsif @locale == 'fr'
      sql_columns +=
        [:generic_french_full_note, :french_full_note]
    end
  end

  def taxon_concepts_json_options
    json_options = super
    json_options[:methods] << :countries_iso_codes
    json_options
  end

  def prepare_main_query
    super()
    @taxon_concepts_rel = @taxon_concepts_rel.
      includes(:current_listing_changes)
  end

end
