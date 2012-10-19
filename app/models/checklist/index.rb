class Checklist::Index < Checklist::Checklist

  def initialize(options={})
    super(options.merge({:output_layout => :alphabetical}))
  end

  def prepare_main_query
    @taxon_concepts_rel = @taxon_concepts_rel.without_nc.without_hidden
  end

  def prepare_kingdom_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_position = 1")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_position = 2")
  end

  def generate
    prepare_queries
    document do |doc|
      content(doc)
    end
    finalize
    @download_path
  end

  def finalize; end

  def columns
    #TODO specific annotation text, generic annotation text, generic annotation full symbol
    res = super + [
      :family_name, :order_name, :class_name, :phylum_name,
      :cites_accepted, :current_listing,
      :generic_annotation_symbol,
      :english_names, :spanish_names, :french_names, :synonyms
    ]
    res -= [:synonyms] unless @synonyms
    res -= [:english_names] unless @english_common_names
    res -= [:spanish_names] unless @spanish_common_names
    res -= [:french_names] unless @french_common_names
    res
  end

end
