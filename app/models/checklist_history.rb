class ChecklistHistory < Checklist

  def initialize(options={})
    super(options.merge({:output_layout => :taxonomic}))

    #need to overwrite whatever was set previously in the order by clause
    @taxon_concepts_rel.order_values = [
      :kingdom_position, :taxonomic_position
    ]
    @taxon_concepts_rel = @taxon_concepts_rel.includes(:m_listing_changes)
  end

end
