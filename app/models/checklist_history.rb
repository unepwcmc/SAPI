class ChecklistHistory < Checklist

  def initialize(options={})
    super(options.merge({
      :output_layout => :taxonomic,
      :synonyms => false
    }))
    @taxon_concept_rel = @taxon_concept_rel.joins(:m_listing_changes)
    @listing_changes_rel = @taxon_concepts_rel
    @listing_changes_rel.select_values = [
      'taxon_concepts_mview.id, listing_changes_mview.*'
    ]
    listing_changes_by_taxon_concept_id = @listing_changes_rel.all.group_by(&:id)
    @taxon_concepts_with_listing_changes = @taxon_concepts_rel.all.map do |tc|
      tc.m_listing_changes = listing_changes_by_taxon_concept_id[tc.id].map do |lc|
        {
          :effective_at => lc.effective_at
        }
      end
    end
  end

end
