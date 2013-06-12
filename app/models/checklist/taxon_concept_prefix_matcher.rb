class Checklist::TaxonConceptPrefixMatcher
  attr_reader :taxon_concepts

  def initialize(search_params)
    @scientific_name = ActiveRecord::Base.send(:sanitize_sql_array, search_params[:scientific_name])
  end

  def taxon_concepts
    build_rel
    @taxon_concepts
  end

  protected

  def build_rel
    @taxon_concepts = MTaxonConcept.by_cites_eu_taxonomy.without_non_accepted.without_hidden
    if @scientific_name
      @taxon_concepts = @taxon_concepts.select("
        DISTINCT id, LENGTH(taxonomic_position),
        full_name, rank_name,
        ARRAY(
          SELECT * FROM UNNEST(synonyms_ary) name WHERE name ILIKE '#{@scientific_name}%'
        ) AS synonyms_ary,
        ARRAY(
          SELECT * FROM UNNEST(english_names_ary) name WHERE name ILIKE '%#{@scientific_name}%'
        ) AS english_names_ary,
        ARRAY(
          SELECT * FROM UNNEST(french_names_ary) name WHERE name ILIKE '#{@scientific_name}%'
        ) AS french_names_ary,
        ARRAY(
          SELECT * FROM UNNEST(spanish_names_ary) name WHERE name ILIKE '#{@scientific_name}%'
        ) AS spanish_names_ary"
      ).
      where("
        full_name ILIKE '#{@scientific_name}%'
        OR
        EXISTS (
          SELECT * FROM UNNEST(synonyms_ary) name WHERE name ILIKE '#{@scientific_name}%'
          UNION
          SELECT * FROM UNNEST(english_names_ary) name WHERE name ILIKE '%#{@scientific_name}%'
          UNION
          SELECT * FROM UNNEST(french_names_ary) name WHERE name ILIKE '#{@scientific_name}%'
          UNION
          SELECT * FROM UNNEST(spanish_names_ary) name WHERE name ILIKE '#{@scientific_name}%'
        )
      ").order("LENGTH(taxonomic_position), full_name")
    end
  end


end

