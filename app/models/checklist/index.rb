class Checklist::Index < Checklist::Checklist

  def initialize(options={})
    super(options.merge({:output_layout => :alphabetical}))
  end

  def prepare_queries
    @animalia_rel = @taxon_concepts_rel.where("kingdom_name = 'Animalia'")
    @plantae_rel = @taxon_concepts_rel.where("kingdom_name = 'Plantae'")
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

end
