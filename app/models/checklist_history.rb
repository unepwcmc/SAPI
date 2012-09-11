class ChecklistHistory < Checklist

  def initialize(options={})
    super(options.merge({:output_layout => :taxonomic}))

    #need to overwrite whatever was set previously in the select clause
    @taxon_concepts_rel.select_values = [
      "data"
    ]
    #need to overwrite whatever was set previously in the order by clause
    @taxon_concepts_rel.order_values = [
      "data->'taxonomic_position'"
    ]
    @taxon_concepts_rel = @taxon_concepts_rel.with_history.
      where('effective_at_ary > ARRAY[]::TIMESTAMP[]')
  end

end
