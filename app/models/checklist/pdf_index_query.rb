class Checklist::PdfIndexQuery
  def initialize(rel, common_names, synonyms)
    @rel = rel
    @common_names = common_names
    @synonyms = synonyms
    #we want common names and synonyms returned as separate records
    #and sorted alphabetically
    shared_columns = [:full_name, :rank_name, :family_name, :class_name,
    :cites_accepted, :current_listing,
    :specific_annotation_symbol, :generic_annotation_symbol,
    :english_names_ary, :spanish_names_ary, :french_names_ary]
    distinct_columns = [:name_type, :sort_name, :lng]
    distinct_columns_values = {
      :name_type => {:basic => "'basic'",
        :english=> "'common'",
        :spanish => "'common'",
        :french => "'common'",
        :synonym => "'synonym'"
      },
      :sort_name => {
        :basic => 'full_name',
        :english => 'UNNEST(english_names_ary)',
        :spanish => 'UNNEST(spanish_names_ary)',
        :french => 'UNNEST(french_names_ary)',
        :synonym => 'UNNEST(synonyms_ary)'
      },
      :lng => {
        :english => "'E'",
        :spanish => "'S'",
        :french => "'F'"
      }
    }
    [:basic, :english, :spanish, :french, :synonym].each do |name_type|
      select_clause = ' SELECT ' + (
        distinct_columns.map do |dc|
          (distinct_columns_values[dc][name_type] || 'null') + " AS #{dc}"
        end + shared_columns
      ).join(',') + ' FROM taxon_concept_matches'
      instance_variable_set("@#{name_type}_select_clause", select_clause)
    end
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