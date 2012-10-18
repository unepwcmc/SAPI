class Checklist::History < Checklist::Checklist

  def initialize(options={})
    super(options.merge({:output_layout => :taxonomic}))
  end

  def prepare_main_query
    @taxon_concepts_rel = @taxon_concepts_rel.where("cites_listed = 't'").
      joins(:m_listing_changes).select('taxon_concept_id').
      where("NOT (listing_changes_mview.change_type_name = 'DELETION' " +
        "AND listing_changes_mview.species_listing_name IS NOT NULL " +
        "AND listing_changes_mview.party_name IS NULL)"
      )
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
    #TODO populations, party name as country name
    res = super + [
      :change_type_name, :species_listing_name,
      :party_name, :effective_at, :is_current,
      :generic_english_full_note, :generic_spanish_full_note,
      :generic_french_full_note,
      :english_full_note, :spanish_full_note, :french_full_note
    ]
    res -= [:generic_english_full_note, :english_full_note] unless @english_common_names
    res -= [:generic_spanish_full_note, :spanish_full_note] unless @spanish_common_names
    res -= [:generic_french_full_note, :french_full_note] unless @french_common_names
    res
  end

end
