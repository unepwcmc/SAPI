class ChecklistHistory < Checklist

  def initialize(options={})
    super(options.merge({
      :output_layout => :taxonomic,
      :synonyms => false
    }))

  end

  def generate(page, per_page)
    @taxon_concepts_rel = @taxon_concepts_rel.where("cites_listed = 't'").includes(:m_listing_changes)
    super(page, 1000)
  end

end
