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
      @scientific_name.upcase!.chomp!
      @taxon_concepts = @taxon_concepts.select(
        ActiveRecord::Base.send(:sanitize_sql_array, [
        "DISTINCT id, ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(taxonomic_position,'\.'), 1),
        full_name, rank_name,
        ARRAY(
          SELECT * FROM UNNEST(synonyms_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
        ) AS synonyms_ary,
        ARRAY(
          SELECT * FROM UNNEST(english_names_ary) name WHERE UPPER(name) LIKE :sci_name_infix
        ) AS english_names_ary,
        ARRAY(
          SELECT * FROM UNNEST(french_names_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
        ) AS french_names_ary,
        ARRAY(
          SELECT * FROM UNNEST(spanish_names_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
        ) AS spanish_names_ary",
        :sci_name_prefix => "#{@scientific_name}%", :sci_name_infix => "%#{@scientific_name}%"
        ])
      ).
      where([
        "UPPER(full_name) LIKE :sci_name_prefix
        OR
        EXISTS (
          SELECT * FROM UNNEST(synonyms_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
          UNION
          SELECT * FROM UNNEST(english_names_ary) name WHERE UPPER(name) LIKE :sci_name_infix
          UNION
          SELECT * FROM UNNEST(french_names_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
          UNION
          SELECT * FROM UNNEST(spanish_names_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
        )
      ", :sci_name_prefix => "#{@scientific_name}%", :sci_name_infix => "%#{@scientific_name}%"
      ]).order("ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(taxonomic_position,'.'), 1), full_name")
    end
  end
end

