module SearchableRelation
  extend ActiveSupport::Concern

  class_methods do
    def search(query, cols = searchable_text_columns)
      ilike_search(query, cols)
    end

    ##
    # Convenience method for building up ILIKE "%foo%" where clauses.
    #
    # SomeModel.ilike_search('foo', [:name, :description_en])
    #
    # is equivalent to:
    #
    # SomeModel.where(%{"name" ilike '%foo%' OR description_en ilike '%foo%'})
    def ilike_search(
      query, cols = searchable_text_columns
    )
      return all if query.blank?

      where(
        cols.map do |col|
          if col.is_a?(Arel::Nodes::NodeExpression)
            col
          else
            if col.is_a?(Arel::Attributes::Attribute)
              col
            else
              arel_table[col.to_s]
            end.matches(
              "%#{sanitize_sql_like(query)}%"
            )
          end
        end.reduce(&:or)
      )
    end

    def searchable_text_columns
      columns.select do |col|
        [ :text, :string ].include? col.type
      end.map(&:name)
    end
  end
end
