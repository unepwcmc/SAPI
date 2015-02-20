class MTaxonConceptFilterByScientificNameWithDescendants

  def initialize(relation, scientific_name, match_options = {})
    @relation = relation || MTaxonConcept.scoped
    @scientific_name = scientific_name.upcase.strip
    @match_synonyms = match_options[:synonyms] || true
    @match_common_names = match_options[:common_names] || false
    @match_subspecies = match_options[:subspecies] || false
  end

  def relation
    subquery = MAutoCompleteTaxonConcept.select(
      'id, ARRAY_AGG_NOTNULL(matched_name) AS matched_names_ary'
    ).
    where(
      ActiveRecord::Base.send(:sanitize_sql_array, [
        "name_for_matching LIKE :sci_name_prefix",
        :sci_name_prefix => "#{@scientific_name}%"
      ])
    ).group(:id)

    @relation = @relation.joins(
      "LEFT JOIN (
        #{subquery.to_sql}
      ) matching_names ON matching_names.id = taxon_concepts_mview.id"
    )

    conditions = []

    cond =<<-SQL
      EXISTS (
        SELECT * FROM UNNEST(ARRAY[kingdom_name, phylum_name, class_name, order_name, family_name, subfamily_name]) name
        WHERE UPPER(name) LIKE :sci_name_prefix
      ) OR matching_names.id IS NOT NULL
    SQL

    conditions << cond

    if @match_subspecies
      cond = <<-SQL
        EXISTS (
          SELECT * FROM UNNEST(subspecies_not_listed_ary) name 
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
