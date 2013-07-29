class Species::TaxonConceptPrefixMatcher
  attr_reader :taxon_concepts

  def initialize(options)
    options = Species::SearchParams.sanitize(options)
    options.keys.each { |k| instance_variable_set("@#{k}", options[k]) }
    return [] unless @taxon_concept_query || !@ranks.empty?
  end

  def taxon_concepts
    build_rel
    @taxon_concepts
  end

  protected

  def build_rel
    @taxon_concepts = MTaxonConcept.order("ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(taxonomic_position,'\.'), 1), full_name")
    unless @ranks.empty?
      @taxon_concepts = @taxon_concepts.where(:rank_name => @ranks)
    end

    @taxon_concepts = if @taxonomy == :cms
      @taxon_concepts.by_cms_taxonomy
    else
      @taxon_concepts.by_cites_eu_taxonomy
    end

    if @taxon_concept_query
      @taxon_concepts = @taxon_concepts.select(
        ActiveRecord::Base.send(:sanitize_sql_array, [
        "id, full_name, rank_name,
        ARRAY(
          SELECT * FROM UNNEST(synonyms_ary) name WHERE name ILIKE :sci_name_prefix
        ) AS synonyms_ary",
        :sci_name_prefix => "#{@taxon_concept_query}%"
        ])
      ).
      where([
        "full_name ILIKE '#{@taxon_concept_query}%'
        OR
        EXISTS (
          SELECT * FROM UNNEST(synonyms_ary) name WHERE name ILIKE :sci_name_prefix
        )
      ", :sci_name_prefix => "#{@taxon_concept_query}%"
      ]).where(:name_status => 'A')
    end
  end

end

