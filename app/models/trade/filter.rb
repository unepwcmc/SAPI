class Trade::Filter
  def initialize(options)
    initialize_params(options)
    initialize_query
  end

  def results
    @query.limit(@options[:per_page]).
      offset(@options[:per_page] * (@options[:page] - 1)).all
  end

  def total_cnt
    @query.count
  end

  private
  
  def initialize_params(options)
    @options = Trade::SearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
  end

  def initialize_query
    @query = Trade::Shipment.includes([
      :exporter, :importer, :country_of_origin, :purpose,
      :source, :term, :unit, :country_of_origin_permit,
      :import_permit, :export_permit, :taxon_concept
    ]).order('year DESC')

    #@query = @taxon_concepts_id.blank? ? "" : TaxonConcept.where(taxon_concepts_ids: @taxon_concepts_ids)




  end

end
