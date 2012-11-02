#Encoding: utf-8
class Checklist::Pdf::Index < Checklist::Index
  include Checklist::Pdf::Document
  include Checklist::Pdf::IndexContent

  def initialize(options={})
    super(options)
    @input_name = 'index'
    @footnote_title_string = "CITES Species Index – <page>"
  end

  def taxon_concepts_columns
    res = super
    res << :specific_annotation_symbol
    res
  end

  def listing_changes_columns
    []
  end

  def prepare_kingdom_queries
    options = {
      :synonyms => @synonyms,
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
