class ChecklistHistory < Checklist

  def initialize(options={})
    super(options.merge({:output_layout => :taxonomic}))

    # select_values = [
      # "taxon_concepts.id", :data,
      # "effective_at",
      # "listing_changes.notes AS listing_notes",
      # "change_types.name AS change_type",
      # "species_listings.abbreviation AS species_listing",
      # "geo_entities.iso_code2 AS party"
    # ]
    # (options[:common_names] || []).each do |lng|
      # select_values << "lng_#{lng.downcase}"
    # end
# 
    # @taxon_concepts_rel.select_values = select_values

    #need to overwrite whatever was set previously in the order by clause
    @taxon_concepts_rel.order_values = [
      :"data -> 'taxonomic_position'"
    ]
    @taxon_concepts_rel = @taxon_concepts_rel.with_history
  end

end
