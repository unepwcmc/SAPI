class Checklist::Index < Checklist::Checklist
  attr_reader :download_name

  def initialize(options={})
    @download_path = download_location(options, "index", ext)

    if !File.exists?(@download_path)
      super(options.merge({:output_layout => :alphabetical}))
    end

    @download_name = "FullChecklist-#{Time.now}.#{ext}"
  end

  def taxon_concepts_columns
    super +
    [:generic_annotation_parent_symbol] -
    [:specific_annotation_symbol]
  end

  def prepare_main_query
    @taxon_concepts_rel = @taxon_concepts_rel.without_nc.without_hidden
  end

  def prepare_kingdom_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_position = 0")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_position = 1")
  end

  def generate
    return @download_path  if File.exists?(@download_path)

    prepare_queries
    document do |doc|
      content(doc)
    end
    @download_path
  end

end
