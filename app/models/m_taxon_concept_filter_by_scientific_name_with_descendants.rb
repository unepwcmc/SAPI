class MTaxonConceptFilterByScientificNameWithDescendants

  def initialize(relation, scientific_name, match_options = {})
    @relation = relation || MTaxonConcept.scoped
    @scientific_name = scientific_name.upcase.chomp
    @match_synonyms = match_options[:synonyms] || true
    @match_common_names = match_options[:common_names] || false
    @match_subspecies = match_options[:subspecies] || false
  end

  def relation
    conditions = ["UPPER(full_name) LIKE :sci_name_prefix"]

    cond =<<-SQL 
      EXISTS (
        SELECT * FROM UNNEST(ARRAY[kingdom_name, phylum_name, class_name, order_name, family_name, subfamily_name]) name
        WHERE UPPER(name) LIKE :sci_name_prefix
      )
    SQL

    conditions << cond
    if @match_synonyms
      cond = <<-SQL
        EXISTS (
          SELECT * FROM UNNEST(synonyms_ary) name
          WHERE UPPER(name) LIKE :sci_name_prefix
        )
      SQL
      conditions << cond
    end

    if @match_common_names
      cond = <<-SQL
        EXISTS (
          SELECT * FROM UNNEST(english_names_ary) name 
          WHERE UPPER(name) LIKE :sci_name_infix
          UNION
          SELECT * FROM UNNEST(french_names_ary) name 
          WHERE UPPER(name) LIKE :sci_name_prefix
          UNION
          SELECT * FROM UNNEST(spanish_names_ary) name 
          WHERE UPPER(name) LIKE :sci_name_prefix
        )
      SQL
      conditions << cond
    end

    if @match_subspecies
      cond = <<-SQL
        EXISTS (
          SELECT * FROM UNNEST(subspecies_ary) name 
          WHERE UPPER(name) LIKE :sci_name_prefix
        )
      SQL
      conditions << cond
    end

    @relation.where(
      conditions.join("\nOR "),
      :sci_name_prefix => "#{@scientific_name}%",
      :sci_name_infix => "%#{@scientific_name}%"
    )
  end

end
