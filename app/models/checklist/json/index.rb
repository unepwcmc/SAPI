class Checklist::Json::Index < Checklist::Index
  include Checklist::Json::Document
  include Checklist::Json::IndexContent

  def initialize(options)
    super(options.merge({:output_layout => :taxonomic}))
    @json_options = json_options
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

  def json_options
    json_options = super
    #just the simple set for the index
    json_options[:only] += [:taxonomic_position, :generic_annotation_symbol, :generic_annotation_parent_symbol]
    json_options[:only] += [:specific_annotation_symbol]
    json_options[:methods] = [:countries_iso_codes] #TODO
    json_options
  end

  def prepare_main_query
    super()
    @taxon_concepts_rel = @taxon_concepts_rel.
      includes(:current_m_listing_changes)
  end

end
