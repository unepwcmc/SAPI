class Checklist::TaxonConceptPrefixMatcher
  attr_reader :taxon_concepts

  def initialize(search_params)
    @scientific_name = search_params[:scientific_name]
  end

  def taxon_concepts
    build_rel
    @taxon_concepts
  end

  protected

  def build_rel
    @taxon_concepts = MTaxonConcept.by_cites_eu_taxonomy.without_non_accepted.without_hidden
    if @scientific_name
      @taxon_concepts = @taxon_concepts.select(
        ActiveRecord::Base.send(:sanitize_sql_array, [
        "DISTINCT id, LENGTH(taxonomic_position),
        full_name, rank_name,
        ARRAY(
          SELECT * FROM UNNEST(synonyms_ary) name WHERE name ILIKE :sci_name_prefix
        ) AS synonyms_ary,
        ARRAY(
          SELECT * FROM UNNEST(english_names_ary) name WHERE name ILIKE :sci_name_infix
        ) AS english_names_ary,
        ARRAY(
          SELECT * FROM UNNEST(french_names_ary) name WHERE name ILIKE :sci_name_prefix
        ) AS french_names_ary,
        ARRAY(
          SELECT * FROM UNNEST(spanish_names_ary) name WHERE name ILIKE :sci_name_prefix
        ) AS spanish_names_ary",
        :sci_name_prefix => "#{@scientific_name}%", :sci_name_infix => "%#{@scientific_name}%"
        ])
      ).
      where([
        "full_name ILIKE '#{@scientific_name}%'
        OR
        EXISTS (
          SELECT * FROM UNNEST(synonyms_ary) name WHERE name ILIKE :sci_name_prefix
          UNION
          SELECT * FROM UNNEST(english_names_ary) name WHERE name ILIKE :sci_name_infix
          UNION
          SELECT * FROM UNNEST(french_names_ary) name WHERE name ILIKE :sci_name_prefix
          UNION
          SELECT * FROM UNNEST(spanish_names_ary) name WHERE name ILIKE :sci_name_prefix
        )
      ", :sci_name_prefix => "#{@scientific_name}%", :sci_name_infix => "%#{@scientific_name}%"
      ]).order("LENGTH(taxonomic_position), full_name")
    end
  end


end

