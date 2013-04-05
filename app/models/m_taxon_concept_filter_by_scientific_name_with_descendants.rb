class MTaxonConceptFilterByScientificNameWithDescendants

  def initialize(relation = MTaxonConcept.scoped, scientific_name)
    @relation = relation
    @scientific_name = scientific_name
  end

  def relation
    @relation.joins(
      <<-SQL
      INNER JOIN (
        SELECT id FROM taxon_concepts_mview
        WHERE (full_name >= '#{TaxonName.lower_bound(@scientific_name)}'
          AND full_name < '#{TaxonName.upper_bound(@scientific_name)}')
          OR (
            EXISTS (
              SELECT * FROM UNNEST(english_names_ary) name WHERE name ILIKE '%#{@scientific_name}%'
              UNION
              SELECT * FROM UNNEST(french_names_ary) name WHERE name ILIKE '#{@scientific_name}%'
              UNION
              SELECT * FROM UNNEST(spanish_names_ary) name WHERE name ILIKE '#{@scientific_name}%'
            )
          )
      ) matches
      ON matches.id IN (#{@relation.table_name}.id, family_id, order_id, class_id, phylum_id, kingdom_id)
      SQL
    )
  end

end