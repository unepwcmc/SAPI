class MTaxonConceptFilterByScientificNameWithDescendants

  def initialize(relation, scientific_name, match_options = {})
    @relation = relation || MTaxonConcept.scoped
    @scientific_name = scientific_name
    @match_synonyms = match_options[:synonyms] || true
    @match_common_names = match_options[:common_names] || false
    @match_subspecies = match_options[:subspecies] || false
  end

  def relation
    conditions = [<<-SQL
      (
        full_name >= '#{TaxonName.lower_bound(@scientific_name)}'
        AND full_name < '#{TaxonName.upper_bound(@scientific_name)}'
      )
    SQL
    ]

    cond =<<-SQL 
      EXISTS (
        SELECT * FROM UNNEST(ARRAY[kingdom_name, phylum_name, class_name, order_name, family_name]) name
        WHERE UPPER(name) LIKE UPPER(BTRIM('#{@scientific_name}%'))
      )
    SQL

    conditions << cond
    if @match_synonyms
      cond = <<-SQL
        EXISTS (
          SELECT * FROM UNNEST(synonyms_ary) name
          WHERE UPPER(name) LIKE UPPER(BTRIM('#{@scientific_name}%'))
        )
      SQL
      conditions << cond
    end

    if @match_common_names
      cond = <<-SQL
        EXISTS (
          SELECT * FROM UNNEST(english_names_ary) name 
          WHERE UPPER(name) LIKE UPPER(BTRIM('%#{@scientific_name}%'))
          UNION
          SELECT * FROM UNNEST(french_names_ary) name 
          WHERE UPPER(name) LIKE UPPER(BTRIM('#{@scientific_name}%'))
          UNION
          SELECT * FROM UNNEST(spanish_names_ary) name 
          WHERE UPPER(name) LIKE UPPER(BTRIM('#{@scientific_name}%'))
        )
      SQL
      conditions << cond
    end

    if @match_subspecies
      cond = <<-SQL
        EXISTS (
          SELECT * FROM UNNEST(subspecies_ary) name 
          WHERE UPPER(name) LIKE UPPER(BTRIM('#{@scientific_name}%'))
        )
      SQL
      conditions << cond
    end

    @relation.where(conditions.join("\nOR "))
  end

end
