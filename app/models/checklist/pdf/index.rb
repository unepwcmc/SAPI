class Checklist::Pdf::Index < Checklist::Index
  include Checklist::Pdf::Document
  include Checklist::Pdf::Helpers
  include Checklist::Pdf::IndexContent

  def initialize(options = {})
    super(options)
    @input_name = 'index'
  end

  def taxon_concepts_json_options
    json_options = super
    json_options[:only] << :ann_symbol
  end

  def prepare_kingdom_queries
    options = {
      :synonyms => @synonyms,
      :authors => @authors,
      :english_common_names => @english_common_names,
      :spanish_common_names => @spanish_common_names,
      :french_common_names => @french_common_names
    }
    super
    @animalia_query = Checklist::Pdf::IndexQuery.new(
      @animalia_rel,
      options
    )
    @plantae_query = Checklist::Pdf::IndexQuery.new(
      @plantae_rel,
      options
    )
  end

end
