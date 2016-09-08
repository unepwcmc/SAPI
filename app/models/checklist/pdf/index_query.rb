class Checklist::Pdf::IndexQuery
  def initialize(rel, options)
    @rel = rel
    @english_common_names = options[:english_common_names]
    @spanish_common_names = options[:spanish_common_names]
    @french_common_names = options[:french_common_names]
    @synonyms = options[:synonyms]
    @authors = options[:authors]
    # we want common names and synonyms returned as separate records
    # and sorted alphabetically
    shared_columns = [:full_name, :rank_name, :family_name, :class_name,
    :cites_accepted, :cites_listing,
    :ann_symbol, :hash_ann_symbol]
    shared_columns << :english_names_ary if @english_common_names
    shared_columns << :spanish_names_ary if @spanish_common_names
    shared_columns << :french_names_ary if @french_common_names
    shared_columns << :author_year if @authors

    distinct_columns = [:name_type, :sort_name, :lng]
    distinct_columns_values = {
      :name_type => {
        :basic => "'basic'",
        :english => "'common'",
        :spanish => "'common'",
        :french => "'common'",
        :synonym => "'synonym'"
      },
      :sort_name => {
        :basic => 'full_name',
        :english => "REGEXP_REPLACE(UNNEST(english_names_ary), '(.+) (.+)', '\\2, \\1')",
        :spanish => 'UNNEST(spanish_names_ary)',
        :french => 'UNNEST(french_names_ary)',
        :synonym =>
          if @authors
            <<-SQL
            UNNEST(ARRAY(SELECT synonym ||
            CASE
            WHEN author_year IS NOT NULL
            THEN ' ' || author_year
            ELSE ''
            END
            FROM (
              (SELECT synonym, ROW_NUMBER() OVER() AS id FROM (SELECT * FROM UNNEST(synonyms_ary) AS synonym) q) synonyms
              LEFT JOIN
              (SELECT author_year, ROW_NUMBER() OVER() AS id FROM (SELECT * FROM UNNEST(synonyms_author_years_ary) AS author_year) q) author_years
              ON synonyms.id = author_years.id
            )
            ))
            SQL
          else
            'UNNEST(synonyms_ary)'
          end
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
    inner_query << " UNION #{@english_select_clause}" if @english_common_names
    inner_query << " UNION #{@spanish_select_clause}" if @spanish_common_names
    inner_query << " UNION #{@french_select_clause}" if @french_common_names
    inner_query << " UNION #{@synonym_select_clause}" if @synonyms

    outer_query = <<-SQL
    WITH name_matches AS (
      #{inner_query}
    )
    SELECT * FROM name_matches WHERE sort_name IS NOT NULL
    ORDER BY UPPER(sort_name) COLLATE "en_GB"
    LIMIT #{limit} OFFSET #{offset}
    SQL
  end

end
