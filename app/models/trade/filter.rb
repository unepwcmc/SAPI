class Trade::Filter
  def initialize(options)
    initialize_params(options)
  end

  def results

  end

  def total_cnt
  end

  private
  
  def initialize_params(options)
    @options = Trade::SearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
  end

  def initialize_query
    
      @query = @taxon_concepts_id.blank? ? "" : TaxonConcept.where(taxon_concepts_ids: @taxon_concepts_ids)

    


  end

end
