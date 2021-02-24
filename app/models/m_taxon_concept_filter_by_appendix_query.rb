class MTaxonConceptFilterByAppendixQuery

  def initialize(relation = MTaxonConcept.all, appendix_abbreviations = [])
    @relation = relation
    @appendix_abbreviations = appendix_abbreviations
    @table = @relation.from_value ? @relation.from_value.first : 'taxon_concepts_mview'
  end

  def initialize_species_listings_conditions(designation_name = 'CITES')
    unless @appendix_abbreviations.empty?
      @appendix_abbreviations_conditions = <<-SQL
        REGEXP_SPLIT_TO_ARRAY(
          #{@table}.#{designation_name.downcase}_listing_original,
          '/'
        ) &&
        ARRAY[#{@appendix_abbreviations.map { |e| "'#{e}'" }.join(',')}]::TEXT[]
      SQL
    end
    @species_listings_ids = SpeciesListing.where(:abbreviation => @appendix_abbreviations).map(&:id)
    @species_listings_in_clause = @species_listings_ids.compact.join(',')
  end

  def relation(designation_name = 'CITES')
    initialize_species_listings_conditions(designation_name)
    @relation.where(@appendix_abbreviations_conditions)
  end

end
