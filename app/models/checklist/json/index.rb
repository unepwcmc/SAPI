class Checklist::Json::Index < Checklist::Index
  include Checklist::Json::Document
  include Checklist::Json::IndexContent

  def initialize(options)
    super(options.merge({:output_layout => :taxonomic}))
  end

  def taxon_concepts_json_options
    json_options = super
    json_options[:methods] -= [
      :ancestors_path, :specific_annotation_symbol, :countries_ids
    ]
    json_options[:methods] << :countries_iso_codes
    json_options
  end

  def listing_changes_json_options
    json_options = super
    json_options[:methods] -= [:countries_ids]
    json_options[:methods] << :countries_iso_codes
    json_options
  end

  def prepare_main_query
    super()
    @taxon_concepts_rel = @taxon_concepts_rel.
      includes(:current_listing_changes)
  end

end
