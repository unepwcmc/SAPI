class Checklist::Index < Checklist::Checklist
  attr_reader :download_name

  def initialize(options={})
    @download_path = download_location(options, "index", ext)

    params = options.merge({:output_layout => :alphabetical})
    # If a cached download exists, only initialize the params for the
    # helper methods, otherwise run the generation queries.
    if !File.exists?(@download_path)
      super(params)
    else
      initialize_params(params)
    end

    @download_name = "FullChecklist-#{Time.now}.#{ext}"
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
