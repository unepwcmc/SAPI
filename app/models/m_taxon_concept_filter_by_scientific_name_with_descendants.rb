class MTaxonConceptFilterByScientificNameWithDescendants

  def initialize(relation, scientific_name, match_options = {})
    @relation = relation || MTaxonConcept.all
    @scientific_name = scientific_name.upcase.strip
    @match_synonyms = match_options[:synonyms] || true
    @match_common_names = match_options[:common_names] || false
    @match_subspecies = match_options[:subspecies] || false
  end

  def relation
    types_of_match = ['SELF']
    types_of_match << 'SYNONYM' if @match_synonyms
    types_of_match << 'COMMON_NAME' if @match_common_names
    types_of_match << 'SUBSPECIES' if @match_subspecies
    subquery = MAutoCompleteTaxonConcept.select(
      'id, ARRAY_AGG_NOTNULL(matched_name) AS matched_names_ary'
    ).
    where(
      ActiveRecord::Base.send(:sanitize_sql_array, [
        "name_for_matching LIKE :sci_name_prefix AND type_of_match IN (:types_of_match)",
        sci_name_prefix: "#{@scientific_name}%",
        types_of_match: types_of_match
      ])
    ).group(:id)

    @relation = @relation.joins(
      "LEFT JOIN (
        #{subquery.to_sql}
      ) matching_names ON matching_names.id = taxon_concepts_mview.id"
    )

    conditions = []

    cond = <<-SQL
      EXISTS (
        SELECT * FROM UNNEST(ARRAY[kingdom_name, phylum_name, class_name, order_name, family_name, subfamily_name]) name
        WHERE UPPER(name) LIKE :sci_name_prefix
      ) OR matching_names.id IS NOT NULL
    SQL

    conditions << cond

    @relation.where(
      conditions.join("\nOR "),
      :sci_name_prefix => "#{@scientific_name}%",
      :sci_name_infix => "%#{@scientific_name}%"
    )
  end

end
