class Checklist::PdfHistoryQuery
  def initialize(rel)
    @rel = rel
  end

  def to_sql(limit, offset)
    inner_query = <<-SQL
      WITH taxon_concept_matches AS (
        #{@rel.to_sql}
      )
    SQL
    inner_query << @basic_select_clause
    if @common_names
      inner_query << " UNION #{@english_select_clause}"
      inner_query << " UNION #{@spanish_select_clause}"
      inner_query << " UNION #{@french_select_clause}"
    end
    if @synonyms
      inner_query << " UNION #{@synonym_select_clause}"
    end

    outer_query = <<-SQL
    WITH name_matches AS (
      #{inner_query}
    )
    SELECT * FROM name_matches WHERE sort_name IS NOT NULL
    ORDER BY sort_name
    LIMIT #{limit} OFFSET #{offset}
    SQL
  end

end