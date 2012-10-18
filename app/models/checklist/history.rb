class Checklist::History < Checklist::Checklist

  def initialize(options={})
    super(options.merge({:output_layout => :taxonomic}))
  end

  def prepare_queries
    @taxon_concepts_rel = @taxon_concepts_rel.where("cites_listed = 't'").
      joins(:m_listing_changes).select('taxon_concept_id').
      where("NOT (listing_changes_mview.change_type_name = 'DELETION' " +
        "AND listing_changes_mview.species_listing_name IS NOT NULL " +
        "AND listing_changes_mview.party_name IS NULL)"
      )
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
