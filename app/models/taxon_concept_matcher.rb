class TaxonConceptMatcher
  attr_reader :taxon_concepts

  def initialize(search_params)
    @taxonomy_options = search_params.taxonomy
    @scientific_name = search_params.scientific_name
    @name_status = search_params.name_status || 'A'
  end

  def taxon_concepts
    build_rel
    @taxon_concepts
  end

  protected

  def build_rel
    @taxon_concepts = initialize_rel
    apply_taxonomy_options_to_rel
    if @scientific_name.present?
      @taxon_concepts = @taxon_concepts.where([
        "UPPER(taxon_concepts.full_name) LIKE BTRIM(UPPER(:sci_name_prefix))",
        :sci_name_prefix => "#{@scientific_name}%"
      ])

    end
  end

  def initialize_rel
    TaxonConcept.where(:name_status => @name_status)
  end

  def apply_taxonomy_options_to_rel
    @taxonomy_id = @taxonomy_options && @taxonomy_options[:id]
    if @taxonomy_id
      @taxon_concepts = @taxon_concepts.where(:taxonomy_id => @taxonomy_id)
    end
  end
end
