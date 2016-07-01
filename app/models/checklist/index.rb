class Checklist::Index < Checklist::Checklist
  attr_reader :download_name

  def initialize(options = {})
    params = options.merge({ :output_layout => :alphabetical })
    @download_path = download_location(params, "index", ext)
    # If a cached download exists, only initialize the params for the
    # helper methods, otherwise run the generation queries.
    if !File.exists?(@download_path)
      super(params)
    else
      initialize_params(params)
    end
  end

  def has_full_options?
    @scientific_name.blank? && @cites_regions.empty? && @countries.empty? && @cites_appendices.empty?
  end

  def prepare_main_query
    @taxon_concepts_rel = @taxon_concepts_rel.without_non_accepted.without_hidden
  end

  def prepare_kingdom_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_position = 0")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_position = 1")
  end

  def generate
    if !File.exists?(@download_path)
      prepare_queries
      document do |doc|
        content(doc)
      end
    end
    ctime = File.ctime(@download_path).strftime('%Y-%m-%d %H:%M')
    doc_name = I18n.t('index_title').split.join('_')
    @download_name = "#{doc_name}_#{has_full_options? ? '' : '[CUSTOM]_'}#{ctime}.#{ext}"
    @download_path
  end

end
